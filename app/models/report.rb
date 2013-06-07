class Report < ActiveRecord::Base

  cattr_accessor :report_date

HEADER = <<-EOD
!!! XML
!!!
%html
  %head
    %title= title
    %meta{"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"}
    %link{"rel" => "stylesheet", "href" => root + "stylesheets/buzz_home.css", "type" => "text/css"}
  %body
    #buzz-top
      %h2= "Buzz Report for " + date.to_s
      %h3= page_title
    #top-banner
      %img{:src => "./images/amazon.gif"}
      %img{:src => "./images/target.gif"}
      %img{:src => "./images/cnet.gif"}
    #mid-banner
      %img{:src => "./images/apple.gif"}
      %img{:src => "./images/futureshop.gif"}
      %img{:src => "./images/bestbuy.gif"}
      %img{:src => "./images/reevoo.png"}
    %hr
EOD

BODY = <<-EOD
    %table
      %tr
        %td
        %td Category
        %td.total-header{:colspan => 2} Latest<br /> Consumer Reviews
      %tr
        %td
        %td
        %td New
        %td All Reviews
      - cats.each do |cat|
        %tr
          %td
            %img{:src => root + "images/" + cat.image_name}
          %td
            %a{:href => root + "c_pages/" + cat.page_name}
              = cat.name
          %td= cat.new_review_count(recent)
          %td= cat.review_count

EOD

  def self.recent
    report_date - 14
  end

  def self.generate_home_page
    cats = Category.order(:position)
    obj = Object.new
    date = report_date
    engine = Haml::Engine.new(HEADER + BODY).def_method(obj, :render,
      :cats, :title, :page_title, :date, :recent, :root)
    f = File.open("#{Rails.root}/public/boseBuzz/home.html", "w")
    root = "./"
    f.puts obj.render(cats: cats, title: "Report",
      page_title: "Bose Consumer Reviews from These Web Forums",
      date: date, recent: recent, root: root)
    f.close
    puts "Done"
    cats.each do |cat|
      CategoryPage.generate_category_page(cat,date,recent)
    end
    nil
  end

end
