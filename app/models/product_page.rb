class ProductPage < ActiveRecord::Base


BODY = <<-EOD
- reviews.each do |review|
  %ul.review-items
    %li= review.forum.name
    %li= review.title
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
    root = "../"
    engine = Haml::Engine.new(Report::HEADER + BODY).def_method(obj, :render,
      :reviews, :title, :page_title, :date, :recent, :root)
    f = File.open("#{Rails.root}/public/boseBuzz/p_pages/#{product.page_name}", "w")
    f.puts obj.render(reviews: reviews, title: "Product Page", page_title: "Page Title",
      date: date, recent: recent, root: root)
    f.close
    puts "Done with Product Page"
  end



end
