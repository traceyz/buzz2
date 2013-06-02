class ReviewsController < ApplicationController

  def index
    @reviews = Review.display(params[:page])
  end
end
