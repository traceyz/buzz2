class CategoryPage < ActiveRecord::Base


BODY = <<-EOD
#category
  #navigation
    %p
      %a{:href => "../home.html"}
        = "Back to the Main Page"
    %hr
  %table
    %tr.first
      %td
        %img{:src => root + "images/" + category.image_name}
      %td#new New
      %td#all All Reviews
    - cats.each do |cat|
      - if cats.count > 1
        %tr
          %td{:colspan => 4}= cat.name
        %tr
          %td{:colspan => 4}
            %hr
      - cat.products.each do |product|
        %tr.product
          %td.p-link
            %a{:href => root + "p_pages/" + product.page_name}
              = product.name
          %td.count= product.new_count(:recent_date => recent, :report_date => date)
          %td.count= product.report_count(date)
        %tr
          %td{:colspan => 4}
            %hr


EOD


  def self.generate_category_page(category,date,recent)
    cats = category.categories.first ? category.categories : [category]
    #products = category.products.order(:name)
    obj = Object.new
    engine = Haml::Engine.new(Report::HEADER + BODY).def_method(obj, :render, :category,:cats, :title, :page_title, :date, :recent, :root)
    root = "../"
    f = File.open("#{Rails.root}/public/boseBuzz/c_pages/#{category.page_name}", "w")
    f.puts obj.render(category: category, cats: cats, title: "Category Page",
      page_title: "Bose Consumer Reviews for #{category.name} from these Forums",
      date: date, recent: recent, root: root)
    f.close
    puts "Done with Category Page"

    cats.each do |cat|
      cat.products.order(&:name).each do |product|
        ProductPage.generate_product_page(product,date,recent)
      end
    end
    puts "Done with Product Pages"

  end


end
