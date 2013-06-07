class ProductPage < ActiveRecord::Base


BODY = <<-EOD
- reviews.each do |review|
  .review_item
    .display
      %img{ :src => root + "images/" + review.forum.image }
      %span.date= review.review_date.to_s
      %span.rating= "Rating: " + review.rating.to_s + " out of 5"
      %p
      %span.display-title= review.display_title
      %span.author= "Author: " + review.author
      - if review.location
        %span.location= "From " + review.location
      %p.headline= review.headline
      %p.body= review.body
      %hr





EOD

  def self.generate_product_page(product,date,recent)
    reviews = product.reviews[0..200]
    obj = Object.new
    #engine = Haml::Engine.new(Report::HEADER + BODY).def_method(obj, :render, :category,:products, :title, :page_title, :date, :recent, :root)
    engine = Haml::Engine.new(Report::HEADER + BODY).def_method(obj, :render, :reviews, :title, :page_title, :date, :recent, :root)
    f = File.open("#{Rails.root}/public/boseBuzz/p_pages/#{product.page_name}", "w")
    root = '../'
    f.puts obj.render(reviews: reviews, title: "Product Page", page_title: "Page Title",date: date, recent: recent, root: root)
    f.close
    puts "Done with Product Page"
  end



end
