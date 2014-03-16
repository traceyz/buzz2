class BoseLinkScraper < ActiveRecord::Base

  require 'open-uri'

  class << self

    FORUM = Forum.where(:name => "Bose").first
    ROOT_LINK = "http://www.bose.com/"
    ALL_LINKS = Set.new

    def get_root_links
      get_links(ROOT_LINK)
    end

    def page_title(page)
      title = page.at_css('title').text
      if title =~ /^Bose[^|]\|\s*([^|]+)\s*\|/
        title = $1
      end
      if title =~ /^([^\-]+)\s\-\s/
        title = $1
      end
      title.gsub(/[^A-z0-9\s\-\.\/]/,'')
    end

    def get_links(link)
      doc = Nokogiri::HTML(open(link))
      nav = doc.at_css('nav#productNav')
      nav.css('li a').each do |link|
        href = link[:href]
        next if href =~ /factory_renewed|accessories/
        next unless ALL_LINKS.add?(href)
        prod_page = Nokogiri::HTML(open(href))
        if prod_page.at_css('section#Customer-Reviews')
          puts "LINK: #{href}"
          puts  "TITLE: #{page_title(prod_page)}"
          puts "PRODUCT:"
          puts
        end

        product_links = prod_page.css('a.product_link').map{|link| link[:href]}

        product_links.each do |product_link|
          product_link = 'http://www.bose.com/controller' + product_link if product_link.start_with?('?')
          next unless ALL_LINKS.add?(product_link)
          page = Nokogiri::HTML(open(product_link))
          puts "LINK: #{product_link}"
          puts  "TITLE: #{page_title(page)}"
          puts "PRODUCT:"
          puts
        end
      end
      nil
    end

  end

end
