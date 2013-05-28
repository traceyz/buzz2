module BbAjax

  def eval_ajax_bb
    path = "#{Rails.root}/lib/load_data/best_buy_ajax_cleaned2.txt"
    doc = Nokogiri::HTML(open(path))
    doc.css('div.BVRRContentReview').each do |review|
      args = {}
      args[:unique_key] = review.attr("id").split("_")[1]
      # if BestBuyReview.where(:unique_key => args[:unique_key]).first
      #   puts "Review already exists"
      #   next
      # end
      text = review.css('span.BVRRReviewTitle').text.strip
      args[:headline] = CGI.unescapeHTML(text)
      args[:rating] = review.css('span.BVRRRatingNumber')[0].text.to_i
      text = review.css('span.BVRRNickname').text.strip
      args[:author] = CGI.unescapeHTML(text)
      text = review.css('span.BVRRUserLocation').text.strip
      args[:location] = CGI.unescapeHTML(text)
      date = review.css('span.BVRRReviewDate').text.strip
      args[:review_date] = date
      text = review.css('span.BVRRReviewText').collect{|c| c.text}.join(" ")
      args[:body] = CGI.unescapeHTML(text)
      puts args.inspect
    end
  end









end
