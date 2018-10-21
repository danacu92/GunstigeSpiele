class SearchSteamController < ApplicationController
    
    def scrape_steam
        require 'open-uri'
        @busqueda = params[:busqueda]
        doc = Nokogiri::HTML(open("https://store.steampowered.com/search/?term="+@busqueda))
        entries = doc.css('a.search_result_row')
        @entriesArray = []
        entries.each do |entry|
            title = entry.css('span.title').text
            id = entry.xpath('@data-ds-appid').text
            linkImage = entry.css("img").attr('src').text
            element = {title:title, id:id, Image:linkImage}
            @entriesArray << element
        end
        render json: @entriesArray
    end

    def obtener_mejor_precio
        title = params[:title].to_s
        id = params[:id].to_s
        monedas=divisas()
        @resultado = []
        @resultado<<scrap_steam_product(id,title)

    end

    def scrap_steam_product(id, title)
        require 'open-uri'
        url_product = "https://store.steampowered.com/app/"+ id
        doc = Nokogiri::HTML(open(url_producto))
        string_precio = ((doc.css('div.game_purchase_price price')[0].text.split("$U"))[1])
        precio= string_precio.to_i
        return {Title:title, Cost:precio, CostoConvertido:precio ,Url:url_product, Currency:'Pesos', Store:'Steam', Enable:'OK'}
    end

    def divisas
        require 'open-uri'
        doc = Nokogiri::HTML(open("https://www.portal.brou.com.uy/home"))
        string_dolar = (doc.css('p.valor')[1].text).gsub(',', '.')
        dolar=string_dolar.to_f
        string_real = (doc.css('p.valor')[9].text).gsub(',', '.')
        real=string_real.to_f
        return {Dolar:dolar, Real:real}
    end

    def scrap_nuuvem(title, real)
        require 'open-uri'
        doc = Nokogiri::HTML(open("https://www.nuuvem.com/catalog/search/"+ title ))
        entries = doc.css('div.product-card--grid')
        entries.each do |entry|
            title_temp = entry.css('a.product-card--wrapper').attr('title').text
    end

    def title_match(title1,title2)
        if (title1.length - title2.length)<2
            
        end
    end

end
