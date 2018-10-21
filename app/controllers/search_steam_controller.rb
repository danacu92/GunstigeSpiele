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
        title = (params[:title].to_s).gsub(/[^[:ascii:]]/, "")
        id = params[:id].to_s
        monedas=divisas()
        @resultado = []
        @nuevoScrap=scrap_steam_product(id,title)
        if @nuevoScrap == 0
          return  render json: {Title:title , Enable:"UNAVAILABLE"}
        end 
        @resultado<<@nuevoScrap
        @nuevoScrap=scrap_nuuvem(title,monedas[:Real])
        if @nuevoScrap != 0
            @resultado<<@nuevoScrap
        end     
       return render json: @resultado   
            
    end

    def scrap_steam_product(id, title)

        require 'open-uri'
        url_product = "https://store.steampowered.com/app/"+ id
        doc = Nokogiri::HTML(open(url_product))
        scrap_precio = doc.css('div.game_purchase_price')[0]
        if scrap_precio !=nil
            string_precio = scrap_precio.text
            precio= ((string_precio.split("$U"))[1]).to_i 
            return {Title:title, Cost:precio, CostoConvertido:precio ,Url:url_product, Currency:'Peso', Store:'Steam', Enable:'OK'}
        else
            return 0 
        end      
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
        encoded_url = URI.encode("https://www.nuuvem.com/catalog/search/"+ title)
        doc = Nokogiri::HTML(open(encoded_url))
        entries = doc.css('div.product-card--grid')
        entries.each do |entry|
            title_temp = entry.css('a.product-card--wrapper').attr('title').text
            if (title_match(title,title_temp)==true)
                string_precio = entry.css('span.integer').text + ((entry.css('span.decimal').text).gsub(',', '.'))
                url_product= entry.css('a.product-card--wrapper').attr('href').text
                puts(url_product)
                precio = string_precio.to_f
                costo_convertido = (string_precio.to_f * real.to_f).round
                if (revisar_region (url_product))
                    return  {Title:title, Cost:precio, CostoConvertido:costo_convertido , Url:url_product, Currency:'Real', Store:'Nuuvem', Enable:'OK'}
                else
                    return  {Title:title, Cost:precio, CostoConvertido:costo_convertido , Url:url_product, Currency:'Real', Store:'Nuuvem', Enable:'NO'}
                end    
            end
        end
        return 0
    end

##########################################################    Metodos Auxiliares     ##########################################################################3

    def revisar_region(url)
        require 'open-uri'
        doc = Nokogiri::HTML(open(url))
        region = doc.css('div.product-widget--content').text
        if ((region.include? "Latin") ||  (region.include? "Uruguay"))
            return true
        else 
            return false 
        end       
    end

    def title_match(title1,title2)
        title1Limpio = (title1.gsub(/[^[:ascii:]]/, "")).downcase
        title2Limpio = (title2.gsub(/[^[:ascii:]]/, "")).downcase
            if (levenshtein_distance(title1Limpio, title2Limpio) == 0)
              return true  
            else
                return false
            end
    end 

    def is_number? (string)
        true if Integer(string) rescue false
    end

        def levenshtein_distance(str1, str2)
            n = str1.length
            m = str2.length
            max = n/2
           
            return m if 0 == n
            return n if 0 == m
            return n if (n - m).abs > max
           
            d = (0..m).to_a
            x = nil
           
            str1.each_char.with_index do |char1,i|
              e = i+1
           
              str2.each_char.with_index do |char2,j|
                cost = (char1 == char2) ? 0 : 1
                x = [ d[j+1] + 1, # insertion
                      e + 1,      # deletion
                      d[j] + cost # substitution
                    ].min
                d[j] = e
                e = x
              end
           
              d[m] = x
            end
           
            x
          end

end