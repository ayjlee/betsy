require "test_helper"

describe ReviewsController do
  let(:product) { products(:soap) }
  let(:review) { reviews(:one) }
  let(:guest_review) { reviews(:guest_review) }

  let(:merchant) { users(:je) }
  let(:another_user) {users(:amy)}
  let(:merchant_product) { products(:candy2) }
  let(:merchant_product_review) {reviews(:candy2_review)}

  describe "reviews#index" do
    #get reviews_path
    # #assert
    # must_respond_with :success
  end

  describe "reviews#new" do
    it "makes a new review from product's show page" do
      get new_product_review_path(product.id)
      must_respond_with :success
    end
  end

  describe "reviews#create" do

    it "creates a review with valid data (must have rating and product_id)" do
      review_data = {
        review: {
          product_id: product.id,
          rating: 5
        }
      }

      start_count = Review.count

      post product_reviews_path(review_data[:review][:product_id]), params: review_data

      Review.count.must_equal start_count + 1

    end

    it "renders bad_request: review is not created without rating" do
      review_data = {
        review: {
          product_id: product.id
        }
      }

      start_count = Review.count

      post product_reviews_path(review_data[:review][:product_id]), params: review_data

      flash[:result_text].must_equal("Error: Could not create your review.")
      must_respond_with :bad_request
      Review.count.must_equal start_count
    end

    it "merchants cannot review their own product" do
      login(merchant)

      review_data = {
        review: {
          product_id: merchant_product.id
        }
      }

      start_count = Review.count

      post product_reviews_path(review_data[:review][:product_id]), params: review_data

      Review.count.must_equal start_count
      flash[:result_text].must_equal "Edit Permissions Denied: As a merchant, you cannot review your own products."

      must_redirect_to product_path(merchant_product.id)
    end

    it "merchants can review other merchants' products " do
      login(merchant)

      review_data = {
        review: {
          product_id: product.id,
          rating: 5
        }
      }

      start_count = Review.count

      post product_reviews_path(review_data[:review][:product_id]), params: review_data

      Review.count.must_equal start_count + 1

      flash[:result_text].must_equal "Successfully created your review!"

      must_redirect_to review_path(Review.last.id)
    end

  end

  describe "reviews#show" do

    it "successfully shows a review page (using review_id)" do
      get review_path(Review.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus review_id" do
      bogus_review_id = Review.last.id + 1
      get review_path(bogus_review_id)
      must_respond_with :not_found
    end
  end

  describe "reviews#edit" do

    it "successfully loads edit review page" do
      get edit_review_path(Review.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus review_id" do
      bogus_review_id = Review.last.id + 1
      get edit_review_path(bogus_review_id)
      must_respond_with :not_found
    end

  end

  describe "reviews#update" do

    describe "when authenticated" do

      it "prevents merchants from updating a review of their own product" do
        login(merchant)

        review_to_update = merchant_product_review

        review_data = {
          review: {
            product_id: merchant_product.id,
            rating: 5
          }
        }

        start_count = Review.count

        patch review_path(review_to_update), params: review_data

        Review.count.must_equal start_count

        flash[:result_text].must_equal "Edit Permissions Denied: As a merchant, you cannot review your own products."

        must_redirect_to review_path(review_to_update)

      end

      it "allows authorized (logged in) users to update their own review" do

        login(merchant)

        review_data = {
          review: {
            product_id: product.id,
            rating: 1
          }
        }

        start_count = Review.count

        post product_reviews_path(review_data[:review][:product_id]), params: review_data

        Review.count.must_equal start_count + 1

        flash[:result_text].must_equal "Successfully created your review!"

        must_redirect_to review_path(Review.last.id)


        review_data = {
          review: {
            product_id: product.id,
            rating: 5
          }
        }

        patch review_path(Review.last.id), params: review_data

        flash[:result_text].must_equal "Successfully updated your review."
        must_redirect_to review_path(Review.last.id)

      end


        it "if Authorized (logged in) user tries to update own review but provide invalid inputs, appropriate errors will display " do
          login(merchant)
          review_data = {
            review: {
              product_id: product.id,
              rating: 5,
              user_id: merchant.id
            }
          }

          post product_reviews_path(product.id), params: review_data

          m_review = Review.last
          start_count = Review.count

          review_data2 = {
            review: {
              rating: nil
            }
          }

          patch review_path(m_review), params: review_data2

          flash[:result_text].must_equal "Error: Could not successfully update your review."

          # must_redirect_to review_path(m_review)

        end

        it "does not allow a logged in user to edit another user's review" do
          review_data = {
            review: {
              product_id: product.id,
              rating: 5,
              user_id: another_user.id
            }
          }

          post product_reviews_path(product.id), params: review_data
          m_review = Review.last

          login(merchant)

          review_data2 = {
            review: {
              product_id: product.id,
              rating: 2
            }
          }

          patch review_path(m_review), params: review_data2

          flash[:result_text].must_equal "Access Denied: You may not edit another user's review."

        end
    end

    describe "when not authenticated" do

      it "does not allow non-logged in users to update a review" do
        review_data = {
          review: {
            product_id: product.id,
            rating: ""
          }
        }

        patch review_path(review), params: review_data

        # flash[:result_text].must_equal "Access Denied: To edit, please log in as a user to edit your own review."

        flash[:result_text].must_equal "Access Denied: To edit, you must have logged in to edit your own review."

        must_redirect_to review_path(review)

        # Verify the DB was not modified
        Review.find(review.id).rating.must_equal review.rating
      end
    end


    it "renders 404 not_found for a bogus review_id" do
      bogus_review_id = Review.last.id + 1
      get review_path(bogus_review_id)
      must_respond_with :not_found
    end

  end

  describe "reviews#destroy" do

    it "does not allow non-authorized (not logged in) users to delete a review" do

      # review_data = {
      #   review: {
      #     product_id: product.id,
      #     rating: 5,
      #     user_id: nil
      #   }
      # }

      delete review_path(review)

      flash[:result_text].must_equal "Access Denied: To delete, please log in as a user to delete your own review."

      must_redirect_to review_path(review)

      # Verify the DB was not modified
      Review.find(review.id).rating.must_equal review.rating

    end

    it "does not allow a merchant to delete others' review " do
      login(merchant)
      get root_path
      
      start_count = Review.count
      delete review_path(review)

      flash[:result_text].must_equal "Access Denied: You may not delete another user's review."
      must_redirect_to root_path
      Review.count.must_equal start_count


    end

    it "allows a merchant to delete a review they wrote" do
      # let(:review) {reviews(:one)}

      login(merchant)
      # get root_path
      review_data = {
        review: {
          product_id: product.id,
          rating: 5,
          user_id: merchant.id
        }
      }

      post product_reviews_path(product.id), params: review_data
      start_count = Review.count

      delete review_path(Review.last.id)
      must_redirect_to root_path

      flash[:result_text].must_equal "Successfully deleted your review!"

      Review.count.must_equal start_count - 1
    end

    it "renders 404 not_found and does not update the DB for a bogus review_id" do
      start_count = Review.count

      bogus_review_id = Review.last.id + 1
      delete review_path(bogus_review_id)
      must_respond_with :not_found

      Review.count.must_equal start_count
    end

  end

end
