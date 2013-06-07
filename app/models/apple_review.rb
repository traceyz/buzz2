class AppleReview < Review
  def display_title
    title.sub(/\ACustomer Reviews:\s+/,'').sub(/\-\s+Apple Store\s+\(U.S.\)\z/,'')
  end
end
