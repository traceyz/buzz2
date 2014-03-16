class ReviewFrom < ActiveRecord::Base

  has_many :reviews
  belongs_to :link_url

  attr_accessible :phrase
  attr_accessible :product_id

  def self.clean(str)
    # str.sub!(/Review from/,'')
    str.sub!(/This review is from:/i,'')
    str.gsub!(/<[^>]+>/,'') # take out tags and links
    str.sub!(/[*]+$/,'')
    str.gsub!(/&[^;]+;/,'') # take out entities
    str.sub!(/New Bose\s*/,'')
    str.sub!(/Bose\s*/i,'')
    str.sub!(/BOSE\s*(R)\s*/,'')
    str.gsub!(/\([^)]+\)/,'') # take out anything in parentheses
    str.sub!(/\s+\-+[^-]+?\z/,'') # take out trailing color variants
    str.gsub!(/;/,'') # take out a lingering semi-colon
    str.strip
  end

  def self.load_original_data(file)
    require 'spreadsheet'
    book = Spreadsheet.open(file)
    line = 1
    book.worksheets.first.each 1 do |row|
      line += 1
      name = row[0].to_s =~ /(\d+)\.\d+/ ? $1.to_i.to_s : row[0]
      product = Product.where(:name => name).first
      unless product
        puts "\tNO PRODUCT FOR #{row[0]} #{line}"
        next
      end
      rf = product.review_froms.create!(:phrase => row[1])
      puts "#{product.name} => #{rf.phrase}"
    end

  end

end
