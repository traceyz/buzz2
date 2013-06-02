class Report < ActiveRecord::Base

  attr_accessible :report_date

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
      %h3 Click on a Categry
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
            %img{:src => cat[:img_path]}
          %td
            %a{:href => cat[:page_path]}
              = cat[:name]
          %td= cat[:new_count]
          %td= cat[:total_count]

EOD

  def recent
    report_date - 14
  end

  def generate_home_page
    args = Category.all.map do |category|
      { name: category.name, new_count: category.new_review_count(recent), total_count: category.review_count}
    end
    obj = Object.new
    date = report_date
    engine = Haml::Engine.new(HEADER + BODY).def_method(obj, :render, :cats, :title, :date)
    f = File.open("#{Rails.root}/haml_buzz/buzz.html", "w")
    f.puts obj.render(cats: args, title: "Report", date: date)
    f.close
    puts "Done"
  end

end
