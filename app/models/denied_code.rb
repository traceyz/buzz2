class DeniedCode < ActiveRecord::Base

  belongs_to :forum
  attr_accessible :code, :forum_id

end
