class ApLinksScraper < ActiveRecord::Base

  require 'open-uri'
  require 'json'

  class << self

    LINK = "http://store.apple.com/us/search/bose"
    NEXT_LINK = "http://store.apple.com/us/searchresults/internal?page=2&term=bose"

    def hello
      puts "Hello"
    end

    def get_links
      #out_file = File.open("ap_links_new.txt", "w")
      page_file = open(LINK)
      page = page_file.read
      page =~/window.searchData =(.+:90000})/m
      data = $1
      json_hash = JSON.parse(data)

      json_hash["results"]["list"].each do |product|
        link = product["url"].sub(/product/, 'reviews')
        unless LinkUrl.where(:link => link).first
          puts link
          puts product["displayName"]
          puts
        end
      end

      if json_hash["results"]["hasMoreResults"]
        puts "LOOKING AT MORE RESULTS"
        page_file = open(NEXT_LINK)
        page = page_file.read
        json_hash = JSON.parse(page)
        json_hash["body"]["results"]["list"].each do |product|
          link = product["url"].sub(/product/, 'reviews')
          unless LinkUrl.where(:link => link).first
            puts link
            puts product["displayName"]
            puts
          end
        end
      end
      nil
      #out_file.close
    end



  end


end
