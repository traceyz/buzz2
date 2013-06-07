class CategoryPage < ActiveRecord::Base


# HEADER = <<-EOD
# !!! XML
# !!!
# %html
#   %head
#     %title= title
#     %meta{"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"}
#     %link{"rel" => "stylesheet", "href" => "buzz.css", "type" => "text/css"}
#   %body
#     #buzz-top
#       %h2 Buzz Report
#     #top-banner
#       %img{:src => "../images/amazon.gif"}
#       %img{:src => "../images/target.gif"}
#       %img{:src => "../images/cnet.gif"}
#     #mid-banner
#       %img{:src => "../images/apple.gif"}
#       %img{:src => "../images/futureshop.gif"}
#       %img{:src => "images/bestbuy.gif"}
#       %img{:src => "../images/reevoo.png"}
#     %hr
#     #nav
#       %h2= date

# EOD

BODY = <<-EOD
    %table
      %tr
        %td.cat-header= "Products in <br />" + category.name + "<br /> Category"
        %td New
        %td Total Reviews
      - products.each do |product|
        %tr
          %td
            %a{:href => "../p_pages/" + product.page_name}
              = product.name
          %td= product.new_review_count(recent)
          %td= product.review_count

EOD


  def self.generate_category_page(category,date,recent)
    products = category.products.order(:name)
    obj = Object.new
    engine = Haml::Engine.new(Report::HEADER + BODY).def_method(obj, :render, :category, :products, :title, :page_title, :date, :recent)
    f = File.open("#{Rails.root}/public/boseBuzz/c_pages/#{category.page_name}", "w")
    f.puts obj.render(category: category, products: products, title: "Category Page", :page_title "",date: date, recent: recent)
    f.close
    puts "Done with Category Page"

    # products.each do |product|
    #   ProductPage.generate_product_page(product,date,recent)
    # end
    puts "Done with Product Pages"

  end


end
