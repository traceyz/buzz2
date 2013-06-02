class ReviewsController < ApplicationController

  def index
    @reviews = Review.order('review_date DESC').first(100)
  end
end
