require 'rubygems'
require 'spreadsheet'

book = Spreadsheet::Workbook.new

sheet1 = book.create_worksheet :name => "Summary"
sheet2 = book.create_worksheet :name => "Details"

sheet1[5,0] = "5,0"
sheet1[0,5] = "0,5"

sheet2[0,0] = "Details"

book.write 'output.xls'
