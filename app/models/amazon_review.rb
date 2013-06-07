class AmazonReview < Review

  def display_title
    title.sub(/\AAmazon.com: Customer Reviews: /,'')
  end
end
