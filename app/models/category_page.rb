class CategoryPage < ActiveRecord::Base


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
      %img{:src => "images/revoo.png"}
    %hr
    #nav
      %h2= date

EOD

BODY = <<-EOD
    %table
      %tr
        %th Product
        %th New
        %th Total Reviews
      - products.each do |product|
        %tr
          %td
            %a{:href => "./p_pages/" + product.name + ".html"}
              = product.name
          %td= product.new_review_count(recent)
          %td= product.review_count

EOD


  def self.generate_category_page(category,date,recent)
    products = category.products.order(:name)
    obj = Object.new
    engine = Haml::Engine.new(HEADER + BODY).def_method(obj, :render, :products, :title, :date, :recent)
    f = File.open("#{Rails.root}/haml_out/c_pages/#{category.page_name}", "w")
    f.puts obj.render(products: products, title: "Category Page", date: date, recent: recent)
    f.close
    puts "Done with Category Page"

    products.each do |product|
      ProductPage.generate_product_page(product,date,recent)
    end
    puts "Done with Product Pages"

  end


end
