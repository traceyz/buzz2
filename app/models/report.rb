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
      %tr.sub-cat
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
    - cats[5..6].each do |cat|
      %tr.sub-cat
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
    - cats[8..9].each do |cat|
      %tr.sub-cat
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


EOD

  def self.recent
    report_date - 14
  end

  def self.generate_home_page
    no_id_count = Review.where("product_id IS NULL").count
    if count > 0
      puts "There are #{count} reviews with no product_id !!"
      return
    end
    cats =  Category.where("category_id IS NULL").order('position ASC, name ASC').reject{|c| c.name == "Multimedia Speakers"}
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
    puts "Home Page Done"
    cats.each do |cat|
      CategoryPage.generate_category_page(cat,date,recent)
    end
    nil
  end

  def self.generate_excel
    generate_xl
    generate_xl(true)
  end

  def self.generate_xl(only_bose = false)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    all_reviews_sheet = book.create_worksheet :name => "All Reviews"
    all_reviews_sheet.row(0).concat %w(Name ReviewFrom Forum Date Author Location Rating Headline Content)
    all_reviews_idx = 1
    args = { :recent_date => recent, :report_date => report_date }
    Category.order('position ASC, name ASC').each do |category|
      next unless category.products.first
      sheet = book.create_worksheet :name => category.name
      sheet.row(0).concat %w(Name ReviewFrom Forum Date Author Location Rating Headline Content)
      idx = 1
      category.products.each do |product|
        reviews = product.new_reviews(args)
        next unless reviews.first
        if only_bose
          reviews = reviews.select{ |r| r.forum.name == "Bose" }
        else
          reviews = reviews.select{ |r| r.forum.name != "Bose" }
        end
        reviews.each do |review|
          row = sheet.row(idx)
          all_reviews_row = all_reviews_sheet.row(all_reviews_idx)
          data = [product.name]
          phrase = review.review_from ? review.review_from.phrase : ""
          data << phrase
          data << review.forum.name
          data << review.review_date.to_s
          data << review.author
          data << review.location || ""
          data << review.rating
          data << review.headline
          data << review.body
          row.concat(data)
          all_reviews_row.concat(data)
          idx += 1
          all_reviews_idx += 1
        end
        idx += 1 if reviews.first # skip a line between products
      end
    end
    sheet = book.create_worksheet :name => "Totals by Forum"
    idx = 0
    Forum.order(:name).each do |forum|
      next if only_bose && forum.name != "Bose"
      count = forum.new_count(args)
      next unless count > 0
      sheet.row(idx)[0] = forum.name
      sheet.row(idx)[1] = count
      puts "#{forum.name} has #{count} new reviews"
      idx += 1
    end
    report_name = only_bose ? "bose_reviews" : "reviews"
    book.write "#{Rails.root}/public/#{report_name}#{report_date.to_s}.xls"
    nil
  end

  def self.dir_name
    "allBuzz#{report_date.strftime("%Y_%m_%d")}"
  end

  def self.package_report
    Dir.mkdir("#{dir_name}")
    FileUtils.cp_r(Dir['public/boseBuzz'], "#{dir_name}")
    FileUtils.cp("public/reviews#{report_date.strftime("%Y-%m-%d")}.xls","#{dir_name}")
    FileUtils.cp("public/bose_reviews#{report_date.strftime("%Y-%m-%d")}.xls","#{dir_name}")
    `zip -r Archive.zip "#{dir_name}"/`
    File.rename('Archive.zip', "#{dir_name}.zip")
    nil
  end

  def self.update_product_ids
    updates = Review.where("product_id IS NULL").each do |review|
      if review.review_from
        review.product_id = review.review_from.product_id
      else
        review.product_id = review.link_url.product.id
      end
      review.save!
    end
    updates.count
  end

end
