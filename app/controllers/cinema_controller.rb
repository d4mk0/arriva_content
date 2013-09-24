# encoding: UTF-8
class CinemaController < ApplicationController
  
  require 'net/http'
  def parse_seances
    kolizey = Cinema.where(:name => "Колизей").first
    megapolis = Cinema.where(:name => "Мегаполис").first
    starlight = Cinema.where(:name => "Старлайт").first
    kinomax_parse(kolizey)
    kinomax_parse(megapolis)
    starlight_parse(starlight)
    flash[:notice] = "Парсинг прошел"
    redirect_to root_path
  end
  
  def show_seances
    @halls = Hall.all
    @halls_map = @halls.map { |h| ['['+h.cinema.name+'] '+h.name, h.id] }
    if params[:information].present? and params[:information][:date].present?
      @current_hall = Hall.where(id: params[:information][:hall]).first
      @seances = Seance.seances_for_day(params[:information][:hall], params[:information][:date])
    end
  end
  
  def create
    if Cinema.create(params[:cinema])
      flash[:notice] = "Кинотеатр \""+params[:cinema][:name]+"\" был добавлен"
    else
      flash[:notice] = "Не добавлен"
    end
    redirect_to cinema_new_path
  end
  
  def new
    @cinemas = Cinema.all
  end
  
  def create_hall
    if Hall.create(params[:hall])
      flash[:notice] = "Кинозал \""+params[:hall][:name]+"\" был добавлен"
    else
      flash[:notice] = "Не добавлен"
    end
    redirect_to new_hall_path
  end
  
  def new_hall
    @cinemas = Cinema.all
    @cinemas_map = @cinemas.map {|c| [c.name, c.id]}
  end
  
  def kinomax_parse(cinema)
    uri = URI(cinema.schedule_address)
    response = Net::HTTP.get_response(uri)
    @source = response.body
    @page = Nokogiri::HTML(response.body)
    @films = @page.css('.filmdesc')
    @films.each do |film|
      filmname = film.css('h1').first.text
      film.css('tr').each do |row|
        day = row.css('.week-day').first
        if day
          date = Time.parse(day.text[4,5]+".2013").strftime("%d.%m.%Y")
          row.css('.time span').each do |time|
            anchor = time.css('a').first
            cinema_information = anchor.present? ? anchor : time
            cinema_information['onmouseover'] =~ %r{.*\('(.*,).'(.*)'}
            hall = $2
            cinema_information['onmouseover'] =~ %r{.*: (\d*)}
            price = $1
            if time.text =~ %r{(([0-1]\d|2[0-3]):([0-5][0-9]))}
              datetime = Time.parse($1+" "+date)
              hall = cinema.halls.where(name: hall).first
              Seance.create(
                hall: hall,
                datetime: datetime,
                film_name: filmname,
                price: price
              )
            end
          end
        end
      end
    end
  end
  
  def starlight_parse(cinema)
    uri = URI(cinema.schedule_address)
    response = Net::HTTP.get_response(uri)
    @source = response.body
    @page = Nokogiri::HTML(response.body)
    @dates = @page.css('.multiplex_schedule')
    @dates.each do |date|
      films = date.css('.msch_group')
      date['id'] =~ %r{s_(.*)}
      date = $1
      films.each do |film|
        film.css('.msch_group_title a').first.text =~ %r{(.*)\(}
        filmname = $1
        @halls = film.css('.msch_hall_title').text.split(/Зал/)#.first.text =~ %r{"(.*)"}
        halls = []
        @halls.each do |h|
          unless h == @halls.first
            h =~ %r{(.*)\d{1}D}
            halls << $1
          end
        end
        lines = film.css('.msch_hall')
        i = 0
        lines.each do |line|
          line.css('a').each do |seance|
            time = seance.css('b').first.text
            seance.text =~ %r{:\d{2}(\d*)}
            price = $1
            hall = halls[i]
            hall = cinema.halls.where(name: "Зал"+hall).first
            datetime = Time.parse(date+" "+time)
            Seance.create(
                hall: hall,
                datetime: datetime,
                film_name: filmname,
                price: price
              )
          end
          i+=1
        end
      end
    end
  end
  
  def send_to_arriva
    http = Net::HTTP.new('adm.arriva.ru')
    path = '/kinoafisha/save_playbill/'
    hall = Hall.find(params[:hall])
    start_date = Time.parse(params[:date])
    end_date = Time.parse("02-10-2013")
    data = ''
    while start_date <= end_date
      date = start_date.strftime("%d.%m.%Y")
      seances = Seance.seances_for_day(params[:hall], date)
      unless seances.blank?
        movies = ''
        times = ''
        prices = ''
        seances.each do |s|
          movies+=CGI.escape(s.film_name)+'%0D%0A'
          times+=CGI.escape(s.datetime.strftime("%H:%M"))+'%0D%0A'
          prices+=CGI.escape(s.price.to_s)+'%0D%0A'
        end
        data = 'data%5Bhall%5D='+hall.id_at_arriva.to_s+
          '&data%5Bdate1%5D='+date+'&data%5Bdate2%5D='+date+
          '&data%5Bmovies%5D='+movies+'&data%5Btimes%5D='+times+
          '&data%5Bprices%5D='+prices+'&data_copy='
        global_data = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path('../../../config/global.yml', __FILE__))))
        par = {'Cookie' => global_data['cookie']}
        http.post(path, data, par)
      end
      start_date+=1.day
    end
    flash[:notice] = 'Размещено на арриве'
    redirect_to request.referer
  end
end
