class ReviewsController < ApplicationController
  before_action :find_review, only: [:show, :edit, :update, :destroy]

  def index
    @reviews= Review.all
  end

  def new
    @review = Review.new
    @product = Product.find_by(id: params[:product_id])
  end

  def create
    @product = Product.find_by(id: params[:product_id])
    if session[:user_id] == @product.user.id
      flash[:status] = :failure
      flash[:result_text] = "Edit Permissions Denied: As a merchant, you cannot review your own products."
      redirect_to product_path(@product.id) and return
    end
    @review = Review.new(review_params)
    @review.product_id = @product.id
    @review.user_id = session[:user_id]
    if @review.save
      flash[:status] = :success
      flash[:result_text] = "Successfully created your review!"
      redirect_to review_path(@review.id)
    else
      flash[:status] = :failure
      flash[:result_text] = "Error: Could not create your review."
      flash[:messages] = @review.errors.messages
      render :new, status: :bad_request
    end
  end

  def show
  end

  def edit
  end

  def update
    if session[:user_id].nil?
      flash[:status] = :failure
      flash[:result_text] = "Access Denied: To edit, you must have logged in to edit your own review."
      redirect_to review_path(@review)

    elsif session[:user_id] == @review.product.user_id
      flash[:status] = :failure
      flash[:result_text] = "Edit Permissions Denied: As a merchant, you cannot review your own products."
      redirect_to review_path(@review)

    elsif session[:user_id] == @review.user_id
      @review.update_attributes(review_params)

      if @review.save
        flash[:status] = :success
        flash[:result_text] = "Successfully updated your review."

        redirect_to review_path(@review.id)
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Error: Could not successfully update your review."
        render :edit, status: :bad_request
      end
    else
      flash[:status] = :failure
      flash[:result_text] = "Access Denied: You may not edit another user's review."
      redirect_to review_path(@review)
    end
  end#of_update

  def destroy
    if session[:user_id].nil?
      flash[:status] = :failure
      flash[:result_text] = "Access Denied: To delete, please log in as a user to delete your own review."
      redirect_to review_path(@review)
    elsif session[:user_id] == @review.user_id
      @review = Review.find_by(id: params[:id]).destroy
      flash[:status] = :success
      flash[:result_text] = "Successfully deleted your review!"
      redirect_to root_path
    else
      flash[:status] = :failure
      flash[:result_text] = "Access Denied: You may not delete another user's review."
      redirect_to root_path
    end
  end
  
  private

  def find_review
    @review = Review.find_by_id(params[:id])
    render_404 unless @review
  end

  def review_params
    params.require(:review).permit(:rating, :text_review)
  end
end
