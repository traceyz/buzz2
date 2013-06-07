class ReevooReview < Review

  def display_title
    title.sub(/\s+\-\s+Reevoo\s+\-\s+Page\s+1\z/,'')
  end

end
