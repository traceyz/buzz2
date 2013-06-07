class AmazonReview < Review

  def title
    super.sub(/\AAmazon.com: Customer Reviews: /,'')
  end
end
