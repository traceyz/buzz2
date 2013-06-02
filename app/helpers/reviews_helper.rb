module ReviewsHelper

  def author_location(review)
    review.location ? "#{review.author} from #{review.location}" : "#{review.author}"
  end

end
