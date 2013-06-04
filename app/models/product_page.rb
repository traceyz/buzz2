class ProductPage < ActiveRecord::Base

HEADER = <<-EOD
!!! XML
!!!
%html
  %head
    %title= title
    %meta{"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"}
    %link{"rel" => "stylesheet", "href" => "buzz.css", "type" => "text/css"}
  %body
    #buzz-top
      %h2 Buzz Report
    #top-banner
      %img{:src => "images/amazon.gif"}
      %img{:src => "images/target.gif"}
      %img{:src => "images/cnet.gif"}
    #mid-banner
      %img{:src => "images/apple.gif"}
      %img{:src => "images/futureshop.gif"}
      %img{:src => "images/bestbuy.gif"}
      %img{:src => "images/reevoo.png"}
    %hr
    #nav
      %h2= date

EOD

BODY = <<-EOD
- reviews.each do |review|
  %ul.review-items
    %li= review.forum.name
    %li= review.review_date.to_s
    %li= "Rating: " + review.rating.to_s
    %li= review.author
    %li.headline= review.headline
    %li= review.body
    %hr

EOD

  def self.generate_product_page(product,date,recent)
    reviews = product.reviews[0..200]
    obj = Object.new
    engine = Haml::Engine.new(HEADER + BODY).def_method(obj, :render, :reviews, :title, :date, :recent)
    f = File.open("#{Rails.root}/haml_out/p_pages/#{product.page_name}", "w")
    f.puts obj.render(reviews: reviews, title: "Product Page", date: date, recent: recent)
    f.close
    puts "Done with Product Page"
  end



end
