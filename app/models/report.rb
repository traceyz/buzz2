class Report < ActiveRecord::Base
  # attr_accessible :title, :body
  RECENT = Date.today - 14
end
