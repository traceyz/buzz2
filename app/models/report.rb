class Report < ActiveRecord::Base

  require 'spreadsheet'

  cattr_accessor :report_date

HEADER = <<-EOD
!!! XML
!!!
%html
  %head
    %title= title
    %meta{"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"}
    %link{"rel" => "stylesheet", "href" => root + "stylesheets/buzz.css", "type" => "text/css"}
  %body
    #header
      #buzz-top
        %h2= "Buzz Report for " + date.strftime("%b %d, %Y")
        %h3= page_title
      #top-banner
        %img{:src => root + "images/amazon.gif"}
        %img{:src => root + "images/target.gif"}
        %img{:src => root + "images/cnet.gif"}
        %img{:src => root + "images/newegg.png"}
      #mid-banner
        %img{:src => root + "images/apple.gif"}
        %img{:src => root + "images/futureshop.gif"}
        %img{:src => root + "images/bestbuy.gif"}
        %img{:src => root + "images/reevoo.png"}
      %hr
EOD

BODY = <<-EOD
.home
  %table
    %tr.first
      %td
      %td Category
      %td.total-header{:colspan => 2} Latest<br /> Consumer Reviews
    %tr.second
      %td
      %td
      %td#new New
      %td#all All Reviews
    %tr
      %td{:colspan => 4}
        %h2 Audio for Video
    - cat = cats[0]
    %tr
      %td{:rowspan => 3}
        %img{:src => root + "images/audio_for_video.png"}
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    - cats[1..2].each do |cat|
      %tr
        %td
          %a{:href => root + "c_pages/" + cat.page_name}
            = cat.name
        %td.count= cat.new_count(:report_date => date, :recent_date => recent)
        %td.count= cat.report_count(date)

    %tr
      %td{:colspan => 4}
        %h2 Video
    - cat = cats[3]
    %tr
      %td
        %img{:src => root + "images/video.png"}
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    %tr
      %td{:colspan => 4}
        %h2 Home Music Systems
    - cat = cats[4]
    %tr
      %td{:rowspan => 3}
        %img{:src => root + "images/home_music_systems.png" }
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    - cat = cats[5]
    %tr
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    - cat = cats[6]
    %tr
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    %tr
      %td{:colspan => 4}
        %h2 Mobile and Computer Audio
    - cat = cats[7]
    %tr
      %td{:rowspan => 3}
        %img{:src => root + "images/mobile_and_computer_audio.png" }
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    - cat = cats[8]
    %tr
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    - cat = cats[9]
    %tr
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)
    - cat = cats[10]
    %tr
      %td{:colspan => 4}
        %h2 Headphones
    %tr
      %td
        %img{:src => root + "images/" + cat.image_name}
      %td
        %a{:href => root + "c_pages/" + cat.page_name}
          = cat.name
      %td.count= cat.new_count(:report_date => date, :recent_date => recent)
      %td.count= cat.report_count(date)

    %tr
      %td{:colspan => 4}
        %h2 Other
    - cats[11..-1].each do |cat|
      %tr
        %td
        %td
          %a{:href => root + "c_pages/" + cat.page_name}
            = cat.name
        %td.count= cat.new_count(:report_date => date, :recent_date => recent)
        %td.count= cat.report_count(date)
EOD

  def self.recent
    report_date - 14
  end

  def self.generate_home_page
    self.report_date = Date.today
    cats =  Category.order('position ASC, name ASC')
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
    # cats.each do |cat|
    #   CategoryPage.generate_category_page(cat,date,recent)
    # end
    nil
  end

  def self.generate_xl
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    args = { :recent_date => recent, :report_date => report_date }
    Category.order('position ASC, name ASC').each do |category|
      next unless category.new_count(args) > 0
      sheet = book.create_worksheet :name => category.name
      sheet.row(0).concat %w(Name Forum Date Author Location Rating Headline Content)
      idx = 1
      category.products.each do |product|
        reviews = product.new_reviews(args)
        next unless reviews.first
        reviews.each do |review|
          row = sheet.row(idx)
          row[0] = product.name
          row[1] = review.forum.name
          row[2] = review.review_date.to_s
          row[3] = review.author
          row[4] = review.location || ""
          row[5] = review.rating
          row[6] = review.headline
          row[7] = review.body
          idx += 1
        end
        idx += 1 # skip a line between products
      end
    end
    sheet = book.create_worksheet :name => "Totals by Forum"
    idx = 0
    Forum.order(:name).each do |forum|
      count = forum.new_count(args)
      next unless count > 0
      sheet.row(idx)[0] = forum.name
      sheet.row(idx)[1] = count
      idx += 1
    end
    book.write "#{Rails.root}/public/reviews#{report_date.to_s}.xls"
    nil
  end

  def self.dir_name
    "allBuzz#{report_date.strftime("%Y_%m_%d")}"
  end

  def self.package_report
    Dir.mkdir("#{dir_name}")
    FileUtils.cp_r(Dir['public/boseBuzz'], "#{dir_name}")
    FileUtils.cp("public/reviews#{report_date.strftime("%Y-%m-%d")}.xls","#{dir_name}")
    `zip -r Archive.zip "#{dir_name}"/`
    File.rename('Archive.zip', "#{dir_name}.zip")
    nil
  end

end
