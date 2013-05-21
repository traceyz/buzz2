$LOAD_PATH << '..'

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'active_record'
require 'utils'


url = "http://www.bestbuy.com/site/Brands/Bose/pcmcat168900050013.c?id=pcmcat168900050013&searchterm=bose&searchresults=1"

ROOT = "http://www.bestbuy.com"

$link_count = 0
$all_links = []
$skuids = []

class ForumProductName < ActiveRecord::Base
end

class Review < ActiveRecord::Base
end

class BoseProduct < ActiveRecord::Base
end

def determine_fpn(review_link)
  #puts "REVIEW LINK #{review_link}"
  reviews_page = Nokogiri::HTML(open(review_link))
  title = reviews_page.at_css("title").text.strip
  title.gsub!(/- Best Buy$/,'')
  title.gsub!(/[^A-z0-9\s]/,"")
  title.gsub!(/\s+/, " ")
  fpn = ForumProductName.find_by_name(title)
  unless fpn
    puts "NIL FPN #{title}"
  end
  fpn
end

def determine_fpn_from_title(title)
  title.gsub!(/- Best Buy$/,'')
  title.gsub!(/[^A-z0-9\s]/,"")
  title.gsub!(/\s+/, " ")
  ForumProductName.find_by_name(title)
end

def build_links(my_url)
  all_categories = Nokogiri::HTML(open(my_url))
  category_links = all_categories.css(".search a")
  category_links.each do |l|
    link = ROOT + l[:href]
    begin
      category_page = Nokogiri::HTML(open(link))
      title = category_page.at_css("title").text
    rescue => e
      puts "unable to get title from #{link}"
      puts e.message
      puts
      next
    end
    next if title =~ /Accessories/
    #note that the mobile solutions category doesn't have a 'sub-categories page'
    #so it doesn't have any matches here.
    #however, all its products show up through the headphones category
    sub_category_links = category_page.css(".info-main h3 a")
    sub_category_links.each do |l|
      stub = ROOT + l[:href]
      next if stub =~ /stand|bracket|remote|kit/i
      stub =~ /^(.+\d+\.p);/
      _link = $1 + '#tab=reviews'
      #puts _link
      begin

        products_page = Nokogiri::HTML(open(_link))
        title = products_page.at_css("title").text.strip
        next if title =~ /Accessories/
        #puts title
        if determine_fpn_from_title(title)
          $all_links << _link #if determine_fpn_from_title(title)
        else
          puts "NIL FPN #{title}"
          puts "AT #{_link}"
        end

      rescue => e
        #some links upset Nokogiri
        puts "\n#{_link}"
        puts e.message
        puts
      end
    end
  end
end


def sku_id(link)
  link =~ /\/(\d+)\.p/
  $1
end

def write_html_links_page
  f = File.open("bb_links_page.html", "w")
  f.puts "<html>"
  f.puts "<head><title>Best Buy Links</title></head>"
  f.puts "<body>"
  f.puts "<ul>"
  $all_links.uniq.each do |link|
    name = link =~ /Bose.+3B\+\-\+([^\/]+)/ ? $1 : link
    f.puts "<li>"
    f.puts "<a href=\"#{link}\">#{name}</a>"
    f.puts "</li>"
    f.puts "<br />"
  end
  f.puts "</ul>"
  f.puts "</body>"
  f.puts "</html>"
  f.close
end

build_links(url)
puts " Gathered links"

if ($all_links.uniq.size == 0)
  puts "didn't find any links"
else
  puts "writing links and checking FPNs"
  $f = File.open("bb_links_list.txt", "w")
  $all_links.uniq.each do |link|
    $f.puts link
    print "L"
  end
  $f.close
  write_html_links_page
end






puts "\nwrote #{$all_links.uniq.size} links"
