require 'rubygems'
require 'haml'

header = 
<<-EOD
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

body = <<-EOD
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

args = [{:img_path => "images/LifestyleDVD.jpg", :page_path => "cPages/LifestyleDVD.html", :name => "Lifestyle DVD-based Systems", :new_count => 10, :total_count => 100},
        {:img_path => "images/LifestyleComponent.jpg", :page_path => "cPages/LifestyleComponent.html", :name => "Lifestyle Component-based Systems", :new_count => 20, :total_count => 200},
        {:img_path => "images/321Systems.jpg", :page_path => "cPages/321Systems.html", :name => "321 Systems", :new_count => 30, :total_count => 300},]
date = "March 12, 2012"
obj = Object.new
engine = Haml::Engine.new(header + body).def_method(obj, :render, :cats, :title, :date)
html_str = obj.render(:cats => args, :title => "Report", :date => date)
f = File.open('home.html', 'w')
f.puts html_str
puts html_str
f.close

puts "done2"