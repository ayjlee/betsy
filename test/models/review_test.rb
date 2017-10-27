require "test_helper"

describe Review do
  let(:review) { reviews(:one) }
  let(:product) { products(:soap)}

  describe "relations" do


    it "has a product" do
      review.must_respond_to :product
      review.must_be_kind_of Review
      review.product.must_be_kind_of Product
    end

  end

  describe "validations" do
    it "requires a rating" do
      review_no_rating = Review.new
      review_no_rating.valid?.must_equal false
      review_no_rating.errors.messages.must_include :rating
    end

    it "rates between 1 and 5" do
      review.rating.must_be_kind_of Integer
      review.rating.must_be :>, 0
      review.rating.must_be :<, 6
      review.rating.must_equal 5
    end

    it "accepts valid ratings" do
      valid_ratings = [1, 2, 3, 4, 5]
      valid_ratings.each do |rating|
        valid_review = Review.new(product_id: product.id, rating: rating)
        valid_review.valid?.must_equal true
      end
    end

    it "rejects invalid ratings" do
      invalid_ratings = ['one', nil,  -1 , 0]
      invalid_ratings.each do |rating|
        bad_review = Review.new(product_id: product.id, rating: rating)
        bad_review.valid?.must_equal false
        bad_review.errors.messages.must_include :rating
      end
    end

  end
end
