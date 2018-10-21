class ApplicationController < ActionController::Base

    def search_steam
        require 'open-uri'
        doc = Nokogiri::HTML(open("https://www.portal.brou.com.uy/home"))
        string_dolar = (doc.css('p.valor')[1].text).gsub(',', '.')
        dolar=string_dolar.to_f
        string_real = (doc.css('p.valor')[9].text).gsub(',', '.')
        real=string_real.to_f
        divisas = {Dolar:dolar, Real:real}
        render json: divisas
    end

   



end
