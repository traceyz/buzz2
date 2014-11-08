class Scraper < ActiveRecord::Base

  require 'open-uri'
  require 'csv'

  class << self

    TOO_OLD = 2014

    def check_links
      total_links = forum.product_links
      total_count = total_links.count
      puts total_count
      count = 0
      total_links.each do |product_link|
        product_link.link_urls.each_with_index do |link_url, index|
          count += 1
          puts "Link #{count} of #{total_count}"
          url = url_from_link(link_url)
          begin
            doc_from_url(url)
          rescue => e
            puts "could not get document from #{url}"
            puts e.message
          end
        end
      end
      nil
    end

    # overide this in the frum specific scraper to limit scraping to specific products
    def specific_product(product_link)
      true
    end

    def get_reviews(all_reviews = false, specific_links = nil)
      file = File.open("#{Rails.root}/errors.txt", "w")
      start = Time.now
      puts "Start: #{start}"
      # file = File.open('test.html', 'w')
      #ActiveRecord::Base.logger = nil
      klass = "#{forum.name}Review"
      total_links = specific_links ? specific_links : forum.product_links
      total_count = total_links.count

      begin

        total_links.each_with_index do |product_link, index|
          puts "LINE 36 **#{product_link.product_id}**"
          next unless specific_product(product_link)
          name = product_link.product.name
          puts "PROCESSING FORUM PRODUCT LINK #{product_link.id}, #{index+1} OUT OF #{total_count}"
          puts "PRODUCT IS #{name}"
          link_set = Set.new

          product_link.link_urls.each do |link_url|
            url = url_from_link(link_url)
            puts "LINK IS #{url}"
            cycle = 0 # check for run-away
            while cycle < 100 && url
              puts "GETTING PAGE FROM #{url}"
              doc = doc_from_url(url)
              unless doc
                puts "BREAK NO DOC FOR #{url}"
                file.puts url
                break
              end
              url = build_reviews_from_doc(doc,link_url,url,klass,all_reviews)
              unless link_set.add?(url)
                puts "LOOP DETECTED : LINK ALREADY VISITED"
                cycle = 100
                break
              end
              cycle += 1
            end
          end
        end

      rescue => e
        puts e.message
        print e.backtrace.join("\n")
      end
      file.close
      finish = Time.now
      puts "End: #{finish}"
      puts "Elapsed time: #{finish - start}"
      nil
    end

    def url_from_link(link_url)
      "#{link_url.forum.root}#{link_url.link}#{link_url.forum.tail}"
    end

    def doc_from_url(url)
      begin
        doc = Nokogiri::HTML(open(url))
      rescue => e
        puts "Unable to get document at #{url}"
        puts e.message
      end
    end

    def get_date(review)
      2014
    end

    def build_reviews_from_doc(doc,link_url,url,klass,all_reviews)
      puts "PAGE FOR #{link_url.product.name}"
      count = 0
      review_class = Object.const_get(klass)
      page_reviews(doc).each do |review|
        year = get_date(review)
        unless year >= TOO_OLD
          #puts "#{year} TOO OLD"
          next
        end
        next unless (key = get_unique_key(review))
        if (r = review_class.where(:unique_key => key).first)
          puts "Review already exists #{r.review_date.to_s}"
          next if all_reviews
          puts "GOT #{count} REVIEWS ON THIS PAGE #{url}"
          return nil
        end
        args = { unique_key: key, link_url_id: link_url.id }
        begin
          next unless (add_args = args_from_review(review, link_url))
        rescue => e
          puts "ERROR #{e.message}"
          return
        end
        args.update(unescape(add_args))
        begin
          the_review = review_class.create!(args)
          raise unless the_review.review_from_id
          puts "REVIEW FROM ID #{the_review.review_from_id}"
          count += 1
        rescue => e
          puts e.message
          puts args.inspect
        end
      end
      puts "GOT #{count} REVIEWS ON THIS PAGE #{url}"
      # review_class.new_count ||= 0
      # review_class.new_count += 1
      # we may need to get all reviews
      #return nil if file
      (count > 0 || all_reviews) ? next_link(doc,link_url,url,klass) : nil
      #next_link(doc,link_url,url,klass)
    end

    def unescape(args)
      coder = HTMLEntities.new
      [:headline, :body, :author, :location].each do |k|
        args[k] = coder.decode(args[k])
      end
      args
    end

    def remove_entities(str)
      str.gsub!(/&amp;/, '&')
      str.gsub!(/&gt;/, '>')
      str.gsub(/&[^&]+;/, ' ')
    end

    # 2011-11-29
    def build_date4(str)
      array = str.split('-')
      yr = array[0].to_i
      mo = array[1].to_i
      day = array[2].to_i
      Date.civil(yr,mo,day)
    end

    # 12/20/2010
    def build_date3(str)
      array = str.split("/")
      yr = array[2].to_i
      mo = array[0].to_i
      day = array[1].to_i
      Date.civil(yr,mo,day)
    end

    def build_date2(str)
      array = str.split(/\s+/)
      yr = array[2].to_i
      mo = MONTHS[array[1]]
      d = array[0].to_i
      Date.civil(yr,mo,d)
    end

    MONTHS = Hash[
      %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec).zip(Array(1..12))]
  # Oct 20, 2011 or October 20, 2011

    # def months
    #   Hash[
    #   %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec).zip(Array(1..12))]
    # end

    def build_date(str)
      yr = year(str)
      mo = MONTHS[str[0..2]] #already an integer
      d = day(str)
      begin
        Date.civil(yr.to_i,mo,d.to_i)
      rescue => e
        puts "invalid date for  #{str}"
        return nil
      end
    end

    def day(str)
      str =~ /\s(\d+),/
      $1
    end

    def year(str)
      str =~ /(\d\d\d\d)/
      $1
    end

    # takes a hash of objects
    # concatenates their values .to_s
    # makes a hex digest of the result
    def build_unique_key(args)
      str = args.values.each_with_object(""){ |elt, s| s << elt.to_s }
      Digest::MD5.hexdigest(str)
    end

    path = '/Users/tracey/Desktop/amazon_links_11_6_AmyCSV.csv'
    def load_amys_links(path, forum_name="Amazon", header=true)
      forum = Forum.where(:name => forum_name).first
      rows = CSV.readlines(path)
      rows.shift if header
      rows.each do |url, title, product_name, category_name|
        print '.'
        next if ['Do not include','broken link'].include?(product_name)
        puts title
        next
        product = Product.where(:name => product_name).first
        raise "NO PRODUCT FOR #{product_name}" unless product
        category = Category.where(:name => category_name).first
        raise "NO CATEGORY FOR #{category_name}" unless category
        raise "#{product.name} does not belong with #{category.name}" unless category.products.include?(product)
        link = forum.link_from_url(url)
        if (lu = LinkUrl.where(:link => link).first)
          puts "LINK #{link} already exists"
        else
          DataLoader.build_link(forum, product, title, link)
        end
      end
      nil
    end

  end

end
