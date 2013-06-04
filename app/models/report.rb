class Report < ActiveRecord::Base

  attr_accessor :report_date

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
      %h3 Click on a Category
      %h3 Return to Home
      %h3 Feedback
EOD

BODY = <<-EOD
    %table
      %tr
        %th Image
        %th Category
        %th New
        %th Total
      - cats.each do |cat|
        %tr
          %td
            %img{:src => Rails.root + "./public/images" + cat.image_name}
          %td
            %a{:href => Rails.root + "./public/c_pages/" + cat.page_name}
              = cat.name
          %td= cat.new_review_count(recent)
          %td= cat.review_count

EOD

  def recent
    report_date - 14
  end

  def generate_home_page
    cats = Category.order(:position)
    obj = Object.new
    date = report_date
    engine = Haml::Engine.new(HEADER + BODY).def_method(obj, :render, :cats, :title, :date, :recent)
    f = File.open("#{Rails.root}/haml_out/home.html", "w")
    f.puts obj.render(cats: cats, title: "Report", date: date, recent: recent)
    f.close
    puts "Done"
    cats.each do |cat|
      CategoryPage.generate_category_page(cat,date,recent)
    end
    nil
  end

end
