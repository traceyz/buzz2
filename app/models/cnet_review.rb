class CnetReview < Review

  def display_title
    title.sub(/\s+\-\s+CNET Reviews\z/,'')
  end

end
