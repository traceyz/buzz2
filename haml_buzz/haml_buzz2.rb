require 'rubygems'
require 'haml'

header = 
<<-EOD
!!! XML
!!!
%html
  %head
    %title= title
  %body
    #top-banner
      %img{:src => "images/amazon.gif"}
      %img{:src => "images/apple.gif"}
      %img{:src => "images/bestbuy.gif"}
    %p
      Some very long content that goes on and on like the text of a very long review and we never know when it will end. it is just a really long paragraph. Of course there can be multiple paragraps as well.
    %table
      %tr
        %th Image
        %th Category
        %th New
        %th Total
EOD

body = <<-EOD
      - cats.each do |cat|
        %tr
          %td Blank
          %td= cat[:name]
          %td= cat[:new_count]
          %td= cat[:total_count]
          
          %table
            - reviews.each do |review|
              %tr
                %td= review

EOD

args = [{:name => "ABC", :new_count => 10, :total_count => 100},
        {:name => "DEF", :new_count => 20, :total_count => 200},
        {:name => "HIJ", :new_count => 30, :total_count => 300}]
        
reviews = ["Review One", "Review Two", "Review Three"]
  
obj = Object.new
engine = Haml::Engine.new(header + body).def_method(obj, :render, :cats, :reviews, :title)
f = File.open("buzz.html", "w")
f.puts obj.render(:cats => args, :reviews => reviews, :title => "Report")
f.close