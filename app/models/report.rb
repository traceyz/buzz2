class Report < ActiveRecord::Base

  attr_accessible :report_date

  def recent
    report_date - 14
  end

end
