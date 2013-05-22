$LOAD_PATH << '..'

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require 'cgi'

require 'utils'

$review_count = 0
FORUM_ID = 23

#before this date we used a different unique key function
#this was the latest review before transferring over to the Mac
CUT_OVER = DateTime.now - 6*7 #Date.civil(2011,6,7)

SECONDS_IN_DAY = 24 * 60 * 60

class ForumProductName < ActiveRecord::Base
end

class Review < ActiveRecord::Base
end

def determine_fpn(title)
  ForumProductName.find_by_name(title)
end



def build_review(link)
  begin
    begin
      doc = Nokogiri::HTML(open(link))
    rescue => e
      puts "unable to get document at #{link}"
      puts e.message
      return
    end
    title = doc.at_css("title").text.sub(/\s+\:.+/,"").strip
    return if title =~ /stand|bracket|battery|bag/i
    fpn = determine_fpn(title)
    puts "FPN NIL *#{title}*" if fpn.nil?
    return if fpn.nil?

    reviews = doc.css(".customer-review-item")
    puts reviews.size.to_s + " REVIEWS"
    reviews.each do |review|

      rating = review.at_css(".rating-score").text
      author = review.at_css(".name").text
      location = review.at_css(".loc").text
      date = review.at_css(".date").text
      if date =~ /(\d+) days ago/
        d = Time.now - ($1.to_i * SECONDS_IN_DAY)
        rev_date = Utils.build_date4("#{d.year}-#{d.month}-#{d.day}")
      else
        rev_date = Utils.build_date(date.strip)
      end
      next unless rev_date
      next if rev_date < CUT_OVER
      # there are some with xx minutes ago, shouldn't be a problem - get them next spin

      summary = review.at_css(".customer-review-title").text
      content = review.at_css("p").text

      next if rev_date <= CUT_OVER
      begin
        Review.create(
          forum_id: FORUM_ID,
          prod_id: fpn.prod_id,
          forum_prod_name_id: fpn.id,
          rev_date: rev_date,
          author: author,
          location: location,
          rating: rating,
          summary: summary,
          content: content,
          uniqueKey: Utils.unique_key(summary,content),
          created_at: Time.now
        )
        puts "review added #{rev_date.to_s}"
        $review_count += 1
      rescue ActiveRecord::RecordNotUnique => e
        puts "record already exists #{rev_date}"
      end
    end
  rescue => e
    puts e.message
    puts e.backtrace.inspect
  end

end

build_review('index')

# links = IO.readlines("fs_links_list.txt")
#
# links.each do |line|
#   link = line.chomp.split(',')[0]
#   build_review(link)
# end
#
# puts "inserted #{$review_count} reviews"
