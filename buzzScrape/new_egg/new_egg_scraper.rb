$LOAD_PATH << '..'

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require 'cgi'

require 'utils'


$review_count = 0
$duplicate_count = 0
FORUM_ID = 28


CUT_OVER = DateTime.now - 6*7 #Date.civil(2011,7,10)

class ForumProductName < ActiveRecord::Base
end

class Review < ActiveRecord::Base
end

def build_reviews(line, duplicate_count )
  url,fpn_name,name = line.split(',')
  fpn = ForumProductName.find_by_name(fpn_name)
  if fpn.nil?
    puts "NIL FPN FOR #{fpn_name}"
    return
  end
  begin

    doc = Nokogiri::HTML(open(url))
  rescue => e
    puts "unable to get document at #{url}"
    puts e.message
    return
  end
  # Newegg.com - Bose&#174; Companion&#174; 2 Series II Multimedia Speaker System => Companion 2 Series II Multimedia Speaker System
  title = doc.at_css("title").text.gsub(/.+Bose/i,"")
  title = title.gsub(/[^A-z0-9\.\s+]+/,"").strip
  title.gsub!(/\s+/," ")
  puts title

  reviews = doc.css('tbody tr')
  puts "Didn't find any reviews" unless reviews.any?
  return unless reviews.any?
  reviews.each do |review|
    review_key = review.at_css("form").attr("name").gsub(/\D/,'')
    author = review.at_css('th.reviewer em').content
    date = review.css('th.reviewer ul li')[1].content.scan(/\d+\/\d+\/\d+/)[0]
    rev_date = Utils.build_date3(date)
    postdate = review.at_css('h3')
    summary = postdate.content.split('/5').last
    rating = postdate.at_css('img.eggs')[:alt].scan(/^\d/)[0]
    comments = review.css('div.details p')
    content = comments.collect{|c| c.content.gsub(/<em\>/,"").gsub(/<\/em>/,"")}.join(" ")
    begin
      Review.create!(
        forum_id: FORUM_ID,
        prod_id: fpn.prod_id,
        forum_prod_name_id: fpn.id,
        rev_date: rev_date,
        author: author,
        rating: rating.to_f,
        summary: summary,
        content: content,
        uniqueKey: Utils.unique_key(summary,content),
        review_key: review_key,
        created_at: Time.now
      )
      puts "review added #{rev_date.to_s}"
      $review_count += 1
    rescue ActiveRecord::RecordNotUnique => e
      puts "record already exists"
    end

  end
end

IO.readlines("ne_links_list.txt").each do |line|
  build_reviews(line,0) if line.length > 0
end
