class BoseScraper < Scraper

  require 'open-uri'
  require 'json'

  class << self

    def forum
      Forum.where(:name => "Bose").first
    end

    LINK = "http://pluck.bose.com/ver1.0/sys/jsonp?widget_path=pluck/reviews/list&plckReviewOnKeyType=article&plckReviewOnKey=solo&plckReviewAuthorAttributeSetKey=Bose_generic_characteristics&plckArticleTitle=Solo%20TV%20sound%20system&plckArticleUrl=http%3A%2F%2Fwww.bose.com%2Fcontroller%3Furl%3D%2Fshop_online%2Fhome_theater%2Ftv_speakers%2Fsolo_tv_sound_system%2Findex.jsp&plckDiscoveryCategories=Home%20Theater%2C%20Speakers%2C%20TV%20Speakers%2C%20One%20speaker%20systems&plckDiscoverySection=Home%20Theater&pluckLang=en&clientUrl=http%3A%2F%2Fwww.bose.com%2Fcontroller%3Furl%3D%2Fshop_online%2Fhome_theater%2Ftv_speakers%2Fsolo_tv_sound_system%2Findex.jsp&cb=plcb2u0"

    def try_links
      page_file = open(LINK)
      page = page_file.read


    end

    def reviews_from_file(link_url_id, path = nil)
      puts LinkUrl.find(link_url_id).product_link.product.name
      path ||= "#{Rails.root}/app/models/bose_files/index"
      doc = Nokogiri::HTML(open(path))
      reviews = doc.css(".pluck-review-full-review-single-review-wrap")
      puts reviews.count
      # reviews.each do |review|
      #   if review.at_css('.item').at_css('a.permalink').attributes.first[1].to_s =~ /plckReviewKey=([A-z0-9_]+)/
      #     puts "REVIEW KEY #{$1}"
      #   else
      #     puts "NO REVIEW KEY"
      #   end
      # end
      # reviews.first.css('div').each{ |d| puts "#{d.to_s}\n"}
      # puts reviews.first.at_css('.pluck-review-full-reviewer-meta p').text
      # puts reviews.first.at_css('.rating').text
      # puts reviews.first.at_css('span.pluck-review-full-timestamp').text
      reviews.each do |r|
        args = {:link_url_id => link_url_id}
        #if r.at_css('.item').at_css('a.permalink').attributes.first[1].to_s =~ /ReviewKey=([A-z0-9_]+)/i
        if r.at_css('.item').at_css('a.permalink').attributes.first[1].to_s =~ /ReviewKey=([A-z0-9]+)/i
          puts "REVIEW KEY #{$1}"
          key = $1
        # elsif r.at_css('.item').to_s =~ /ReviewKey=([A-z0-9_\-]+)/
        #   key = $1
        else
          puts "NO REVIEW KEY"
          next
        end
        if BoseReview.where(:unique_key => key).first
          puts "Review already exists #{key}"
          next
        end
        args[:unique_key] = key
        args[:rating] = r.at_css('.rating').text.to_i
        date = r.at_css('span.pluck-review-full-timestamp').text
        args[:review_date] = build_date3(date)
        args[:author] = r.at_css('.pluck-review-full-reviewer-meta p').text.sub('Posted by','').strip
        args[:headline] = r.at_css('p.summary').text
        args[:body] = r.at_css('.description').text
        BoseReview.create!(args)
      end
      nil
    end

    def all_links
      forum = Forum.where(:name => "Bose").first
      forum.product_links.each do |pl|
        #puts "#{pl.id} #{pl.product_id}"
        pl.link_urls.each do |lu|
          puts "\n#{forum.root}#{lu.link}"
          puts "#{lu.id} #{lu.title}"

        end
      end
      nil
    end
  end

end
