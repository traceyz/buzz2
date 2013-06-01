class NewEggScraper < Scraper

  def self.forum
    Forum.find_by_name("NewEgg")
  end

  def self.page_reviews(doc)
    doc.css('tbody tr')
  end

  def self.get_unique_key(review)
    review.at_css("form").attr("name").gsub(/\D/,'')
  end

  def self.args_from_review(review)
    date_str = review.css('th.reviewer ul li')[1].content.scan(/\d+\/\d+\/\d+/)[0]
    postdate = review.at_css('h3')
    postdate.at_css('img.eggs')[:alt].scan(/^\d/)[0]
    {
      review_date: build_date3(date_str),
      headline: postdate.content.split('/5').last,
      rating: postdate.at_css('img.eggs')[:alt].scan(/^\d/)[0].to_i,
      author: review.at_css('th.reviewer em').content,
      body: review.css('div.details p').map{
        |c| c.content.gsub(/<em\>/,"").gsub(/<\/em>/,"") }.join(" "),
      location: "NA"
    }
  end

  def self.next_link(doc,link_url,url,klass)
    #http://www.newegg.com/Product/Product.aspx?Item=36-166-004&SortField=0&SummaryType=0&Pagesize=10&PurchaseMark=&SelectedRating=-1&VideoOnlyMark=False&VendorMark=&IsFeedbackTab=true&Keywords=%28keywords%29&Page=11#scrollFullInfo
    #increase the page umber until reviews repeat
    #however, links are currently of the form Product.aspx?Item=N82E16826627012
    nil
  end
end
