$LOAD_PATH << '..'

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'

require 'utils'



url = "http://www.newegg.com/Product/ProductList.aspx?Submit=ENE&N=50009959&IsNodeId=1&Manufactory=9959&bop=And&SpeTabStoreType=0&Pagesize=100"
ROOT = "http://www.newegg.com"
$link_count = 0

"http://www.newegg.com/Product/ProductReview.aspx?Item=N82E16855998977"

class ForumProductName < ActiveRecord::Base
end

class BoseProduct < ActiveRecord::Base
end

def extract_fpn(link_url)
  begin

    doc = Nokogiri::HTML(open(link_url))
  rescue => e
    puts "unable to get document at #{url}"
    puts e.message
    return
  end
  # Newegg.com - Bose&#174; Companion&#174; 2 Series II Multimedia Speaker System => Companion 2 Series II Multimedia Speaker System
  title = doc.at_css("title").text.gsub(/.+Bose/i,"Bose")
  title.gsub!(/Newegg.com/, '')
  title.gsub!(/\([^\)]+\)/,"") # remove text wrapped in parentheses
  title.sub!(/Right.+$/,"")
  title.sub!(/Left.+$/,"")
  title = title.gsub(/[^A-z0-9\.\s+]+/,"").strip
  title.gsub!(/\s+/," ")
  puts title
  fpn = ForumProductName.find_by_name(title)
  unless fpn
    puts "\tNIL FPN"
    puts title
    puts link_url
  end
  fpn
end

def build_links(my_url)
  doc = Nokogiri::HTML(open(my_url))
  doc.css("a[class='itemRating']").collect{|a| a[:href]}.uniq
end


links = build_links(url)
if links.size == 0
  puts "No links found"
else
  puts "found #{links.size} on the page"
  count = 0
  f = File.open("ne_links_list.txt", "w")
  links.uniq.each do |link|
    fpn = extract_fpn(link)
    next unless fpn
    product = BoseProduct.find(fpn.prod_id)
    f.puts "#{link},#{fpn.name},#{product.name}"
    count += 1
  end
  puts "wrote #{count} links"
  f.close

end

