# encoding: UTF-8
class CinemaController < ApplicationController
  
  require 'net/http'
  def parse_seances
    kolizey = Cinema.where(:name => "Колизей").first
    megapolis = Cinema.where(:name => "Мегаполис").first
    starlight = Cinema.where(:name => "Старлайн").first
    kinomax_parse(kolizey)
    kinomax_parse(megapolis)
    flash[:notice] = "Парсинг прошел"
    redirect_to root_path
  end
  
  def show_seances
    @halls = Hall.all
    @halls_map = @halls.map { |h| ['['+h.cinema.name+'] '+h.name, h.id] }
    if params[:information].present?
      @current_hall = Hall.where(id: params[:information][:hall]).first
      @seances = seances_for_day(params[:information][:hall], params[:information][:date])
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
end
