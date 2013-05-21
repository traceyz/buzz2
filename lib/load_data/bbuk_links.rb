$LOAD_PATH << '..'

require 'rubygems'
require 'nokogiri'
require 'active_record'
require 'open-uri'

require 'utils'

$f = File.open("links_list.txt", "w")

url = "http://shopping.reevoo.com/search?q=bose"
ROOT = "http://shopping.reevoo.com"

$all_links = []

def build_links(my_url)
  begin
    doc = Nokogiri::HTML(open(my_url))
  rescue => e
    puts e.message
    return
  end
  links = doc.css("a[class='reviews']")
  links.each do |l|
    #we only want ones that have reviews
   next unless l.text =~ /Read \d+ reviews/im
   link =  ROOT + l[:href]
   #we don't track products that aren't bose
   next unless link =~ /bose/i
   #we don't track these products
   next if link =~ /bag/ || 
           link =~ /kit/ || 
           link =~ /uts20/ || 
           link =~ /ufs20/ || 
           link =~ /mount/ || 
           link =~ /enhancer/
   link.gsub!(/#reviews/,"")
   link += "/page/1"
   $all_links << link

  end
  
  next_anchor = doc.at_css("a[class='next_page']")
  unless next_anchor.nil?
    next_link = ROOT + next_anchor[:href]
    puts next_link
    build_links(next_link)
  end
  
end

build_links(url)

def determine_fpn(doc)
  prod_name = doc.at_css("title").text.sub(/\sReviews.+/i,"")
  fpn = ForumProductName.find_by_name(prod_name)
  puts "NIL FPN for #{prod_name}" if fpn.nil?
  fpn
end

class ForumProductName < ActiveRecord::Base
end

class BoseProduct < ActiveRecord::Base
end

$all_links.each do |link|
  doc = Nokogiri::HTML(open(link))
  fpn = determine_fpn(doc)
  puts "NIL FPN for #{link}" unless fpn
  next unless fpn
  product = BoseProduct.find(fpn.prod_id)
  $f.puts "#{link},#{fpn.name},#{product.name}"
end


puts "wrote #{$all_links.size} links"