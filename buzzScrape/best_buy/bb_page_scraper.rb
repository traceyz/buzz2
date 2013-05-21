$LOAD_PATH << '..'

# adapted from the web scraper to handle one page of source at a time
# use this until I can get the generated source directly from the web site

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require 'cgi'

require 'utils'

$review_count = 0
FORUM_ID = 26
ROOT = "http://www.bestbuy.com"
CUT_OVER = DateTime.now - 6*7 #Date.civil(2011,7,8)

class ForumProductName < ActiveRecord::Base
end

class Review < ActiveRecord::Base
end

def determine_fpn(title)
  title.gsub!(/[^A-z0-9\s]/,"")
  title.gsub!(/\s+/, " ")
  title.sub!(/Best Buy$/,'')
  puts "TITLE #{title}"
  ForumProductName.find_by_name(title)
end


def process_review_page
  begin
    reviews_page = Nokogiri::HTML(open('index'))
    title = reviews_page.at_css("title").text.strip
    fpn = determine_fpn(title)
    puts "NIL FPN for #{title}" if fpn.nil?
    return if fpn.nil?
  rescue => e
    puts e.message
    return
  end

  #reviews = reviews_page.css('div#BVRRContainer > div > div')
  reviews = reviews_page.css('div.BVRRContentReview')

  return if reviews.nil? || reviews.empty?
  reviews.each do |r|
    review_key = r.attr("id").split("_")[1]
    text = r.css('span.BVRRReviewTitle').text
    headline = CGI.unescapeHTML(text)
    #puts "TITLE #{title}"
    rating = r.css('span.BVRRRatingNumber')[0].text
    #puts "RATING #{rating}"
    text = r.css('span.BVRRNickname').text
    author = CGI.unescapeHTML(text)
    #puts "AUTHOR #{author}"
    text = r.css('span.BVRRUserLocation').text
    location = CGI.unescapeHTML(text)
    #puts puts "LOCATION #{location}"
    date = r.css('span.BVRRReviewDate').text
    rev_date = Utils.build_date3(date)
    #puts "DATE #{date} #{Utils.build_date3(date)}"
    text = r.css('span.BVRRReviewText').collect{|c| c.text}.join(" ")
    content = CGI.unescapeHTML(text)
    #puts "CONTENT #{content}"

    begin
      Review.create!(
        forum_id: FORUM_ID,
        prod_id: fpn.prod_id,
        forum_prod_name_id: fpn.id,
        rev_date: rev_date,
        author: author,
        location: location,
        rating: rating,
        headline: headline,
        content: content,
        uniqueKey: Utils.unique_key(headline+content),
        review_key: review_key,
        created_at: Time.now
      )
      puts "review added #{rev_date.to_s}"
      $review_count += 1
    rescue ActiveRecord::RecordNotUnique => e
      puts "#{rev_date} record already exists"
    end
  end

end

process_review_page

# IO.readlines("bb_links_list.txt").each do |line|
#   link = line.chomp.split(',')[0]
#   process_review_page(link)
# end

# process_review_page("http://www.bestbuy.com/site/Bose%26%23174%3B+-+LIFESTYLE%26%23174%3B+V35+Home+Entertainment+System/9824482.p#tab=reviews")

#process_review_page("http://www.bestbuy.com/site/Bose%26%23174%3B+-+LIFESTYLE%26%23174%3B+V25+Home+Entertainment+System/9824289.p?skuId=9824289&id=1218178658247#tabbed-customerreviews")

puts "inserted #{$review_count} reviews"
