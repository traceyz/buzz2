class NewEggReview < Review

  def display_title
    title.sub(/\s+\-\s+Newegg.com\z/,'')
  end

end
