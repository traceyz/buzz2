class ProductPage < ActiveRecord::Base


BODY = <<-EOD
#navigation
  %p
    %a{:href => "../home.html"}
      = "Back to the Main Page"
    %a{:href => "../c_pages/" + category.page_name}
      = "Back to the " + category.parent_name + " Page"
  %hr
- reviews.each do |review|
  .review_item
    %input{:type => "hidden", :value=>review.unique_key, :name=>:unique_key}
    %input{:type => "hidden", :value=>review.link, :name=>:link}
    %input{:type => "hidden", :value =>review.link_url_id, :name=>:link_url_id}
    %img{ :src => root + "images/" + review.forum.image }
    %span.date= review.review_date.strftime("%b %d, %Y")
    %span.rating= "Rating: " + review.rating.to_s + " out of 5"
    -if review.review_date >= recent
      %img{ :src => root + "images/new_small.gif", :class => "new-img" }
    %p.display-title= review.display_title
    -if review.review_from && review.review_from.phrase
      %p.review_from= "Review from: " + review.review_from.phrase
    -if review.style
      %p.review_style= review.style
    %p.author= "Author: " + review.author
    - if review.location
      %span.location= "From " + review.location
    %p.headline= review.headline
    %p.body= review.body
    %hr

EOD

  def self.generate_product_page(product,date,recent)
    reviews = product.report_reviews(date)
    obj = Object.new
    engine = Haml::Engine.new(Report::HEADER + BODY).def_method(obj, :render, :category, :reviews, :title, :page_title, :date, :recent, :root)
    f = File.open("#{Rails.root}/public/boseBuzz/p_pages/#{product.page_name}", "w")
    root = '../'
    f.puts obj.render(category: product.category, reviews: reviews, title: "Product Page",
      page_title: "Bose Consumer Reviews for #{product.name} from these Forums",
      date: date, recent: recent, root: root)
    f.close
    puts "Done with Product Page"
  end



end
