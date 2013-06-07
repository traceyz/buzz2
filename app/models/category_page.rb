class CategoryPage < ActiveRecord::Base


BODY = <<-EOD
    %table
      %tr
        %td.cat-header= "Products in <br />" + category.name + "<br /> Category"
        %td New
        %td Total Reviews
      - products.each do |product|
        %tr
          %td
            %a{:href => root + "p_pages/" + product.page_name}
              = product.name
          %td= product.new_review_count(recent)
          %td= product.review_count

EOD


  def self.generate_category_page(category,date,recent)
    products = category.products.order(:name)
    obj = Object.new
    engine = Haml::Engine.new(Report::HEADER + BODY).def_method(obj, :render, :category,:products, :title, :page_title, :date, :recent, :root)
    root = "../"
    f = File.open("#{Rails.root}/public/boseBuzz/c_pages/#{category.page_name}", "w")
    f.puts obj.render(category: category, products: products, title: "Category Page", page_title: "",date: date, recent: recent, root: root)
    f.close
    puts "Done with Category Page"

    products.each do |product|
      ProductPage.generate_product_page(product,date,recent)
    end
    puts "Done with Product Pages"

  end


end
