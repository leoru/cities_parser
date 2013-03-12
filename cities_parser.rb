# encoding: UTF-8

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'colorize'
require 'plist'

def perform_replace_sting(str)
  coords_with_comma = str.gsub(" с.ш.",";")
  coords_with_comma = coords_with_comma.gsub(" в.д.","")
  coords_with_comma = coords_with_comma.gsub("° ",",")
  coords_with_comma = coords_with_comma.gsub("'","")
  return coords_with_comma
end

# массив городов
cities = Array.new

# страниц всего 6
(0..6).each do |page|

  page_string = 'http://worldgeo.ru/russia/lists/?id=25&page='+page.to_s
  pagefile = open(page_string)
  page = Nokogiri::HTML(pagefile)

  maintable = page.css("table[width='580']")

  trs = maintable.css('tr').select

  trs.each_with_index do |tr,index|
    if (index < trs.count - 1)
      city = Hash.new

      tds = tr.css('td').select
      tds.each_with_index do |td,index|

        if (index == 1)
          name = td.css('nobr').text
          city["name"] = name
        end

        if (index == 5)
          coords = td.text
          coords_with_comma = perform_replace_sting(coords)
          coords = coords_with_comma.split(";")
          city["lat"] = coords[0]
          city["lng"] = coords[1]
        end

      end

      cities << city

    end

  end

end

citiesHash = Hash.new
citiesHash["cities"] = cities

plist =  citiesHash.to_plist

File.open("cities.plist", 'w') {|f| f.write(plist) }

puts "Success"

