class FutureShopReview < Review

  def display_title
    title.sub(/\s+\-\s+Future\s+Shop\z/,'')
  end

end
