# encoding: UTF-8
class CinemaController < ApplicationController
  
  require 'net/http'
  def index
    Film.destroy_all
    uri = URI('http://www.kinomax.ru/index2.php?r=schedule/cinema&id=kolizey')
    response = Net::HTTP.get_response(uri)
    @source = response.body
    @page = Nokogiri::HTML(response.body)
    @films = @page.css('.filmdesc')
    @dates = {}
    @films_hash = {}
    @all_films = []
    @counter = 0
    @films.each do |film|
      filmname = film.css('h1').first.text
      @films_hash[filmname] = {}
      film.css('tr').each do |row|
        day = row.css('.week-day').first
        if day
          date = Time.parse(day.text[4,5]+".2013").strftime("%d.%m.%Y")
          @films_hash[filmname][date] = {}
          row.css('.time span').each do |time|
            anchor = time.css('a').first
            holl = ''
            cinema_information = anchor.present? ? anchor : time
            cinema_information['onmouseover'] =~ %r{.*\('(.*,).'(.*)'}
            holl = $2
            cinema_information['onmouseover'] =~ %r{.*: (\d*)}
            price = $1
            @films_hash[filmname][date][holl] = "" unless @films_hash[filmname][date][holl]
            if time.text =~ %r{(([0-1]\d|2[0-3]):([0-5][0-9]))}
              @films_hash[filmname][date][holl] += $1+" "+price+" "
              Film.create(
                :hall_name => holl,
                :date => date,
                :name => filmname,
                :time => $1,
                :price => price
              )
              @counter += 1
            end
          end
        end
      end
    end
    @films = Film.where(:hall_name => "VIP зал", :date =>"19.09.2013")
    
  end
  
  def show_films
    if params[:information].present?
      @films = Film.order(:time).where(:hall_name => params[:information][:hall], :date => params[:information][:date])
    end
  end
end
