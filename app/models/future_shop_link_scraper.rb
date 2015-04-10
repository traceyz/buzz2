class FutureShopLinkScraper < ActiveRecord::Base
  # attr_accessible :title, :body
  require "net/http"
  require "uri"
  require "csv"

  ROOT = "http://www.futureshop.ca/en-CA/product/"

  def self.establish_links_from_file
    ActiveRecord::Base.logger.level = 1
    path = "#{Rails.root}/app/models/future_shop_files/links2.html"
    doc = Nokogiri::HTML(open(path))
    links = doc.css('a').select{|l|  l[:href] =~ /\/product\//}.map{|l| l[:href]}
    links.each{ |link| link.sub!(/\?path=.+/,'')}
    links.each{ |link| link.sub!(/.+product\//, '')}
    # links.uniq.sort.each{ |link| puts link }
    have_count = 0
    links.uniq.sort.each do |link|
      lu = LinkUrl.where(:link => link).first
      if lu
        have_count += 1
      else
        puts link
        begin
          doc = Nokogiri::HTML(open(ROOT + link))
          str = doc.at_css('title').text.strip
          title = str.sub(/\s+\:.+/,'')
          puts title
        rescue => e
          puts e.message
        end
        puts
      end
    end
    puts "HAD #{have_count} LINKS"
    nil
  end

  def self.build_links_from_file
    path = "#{Rails.root}/app/models/future_shop_files/links_sheet.csv"
    forum = Forum.where(:name => "FutureShop").first
    CSV.read(path)[1..-1].each do |(link, title, product_id)|
      product_link = forum.product_links.where(:product_id => product_id).first ||
                              forum.product_links.create!(:product_id => product_id)
      product_link.link_urls.where(:link => link).first ||
      product_link.link_urls.create!(:link => link, :title => title, :current => true)
    end

    nil
  end

end
