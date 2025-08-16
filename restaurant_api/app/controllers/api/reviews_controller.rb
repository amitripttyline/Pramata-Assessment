class Api::ReviewsController < ApplicationController
  before_action :authenticate_request!, except: [:index]
  before_action :set_review, only: [:update, :destroy]

  def index
    @reviews = Review.includes(:user, :reservation)
                    .recent

    # Filter by rating if provided
    @reviews = @reviews.by_rating(params[:rating]) if params[:rating].present?
    
    # Pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    @reviews = @reviews.limit(per_page.to_i).offset((page.to_i - 1) * per_page.to_i)

    render json: {
      reviews: @reviews.map { |r| review_response(r) },
      meta: {
        average_rating: Review.average_rating,
        rating_distribution: Review.rating_distribution,
        total_reviews: Review.count
      }
    }
  end

  def create
    @reservation = current_user.reservations.find(params[:reservation_id])
    
    unless @reservation.completed?
      return render json: { error: 'Can only review completed reservations' }, status: :unprocessable_entity
    end

    @review = current_user.reviews.build(review_params)
    @review.reservation = @reservation

    if @review.save
      render json: {
        review: review_response(@review),
        message: 'Review created successfully'
      }, status: :created
    else
      render json: { errors: @review.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @review.update(review_params)
      render json: {
        review: review_response(@review),
        message: 'Review updated successfully'
      }
    else
      render json: { errors: @review.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    render json: { message: 'Review deleted successfully' }
  end

  private

  def set_review
    @review = current_user.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def review_response(review)
    {
      id: review.id,
      rating: review.rating,
      comment: review.comment,
      created_at: review.created_at,
      user: {
        id: review.user.id,
        name: review.user.name
      },
      reservation: {
        id: review.reservation.id,
        reservation_date: review.reservation.reservation_date,
        table_name: review.reservation.table.name
      }
    }
  end
end
