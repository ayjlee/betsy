require "test_helper"

describe OrderItemsController do
  let(:chocolate1) { order_items(:orderitem1) }
  let(:soap2) { order_items(:orderitem2)}

  describe "OrderItem#index" do
    it "succeeds when there are OrderItems" do
      chocolate1
      OrderItem.count.must_be :>, 0, "No OrderItems in the test fixtures"
      get order_items_path
      must_respond_with :success
    end

    it "succeeds when there are no OrderItems" do
      OrderItem.destroy_all
      get order_items_path
      must_respond_with :success
    end
  end

  describe "OrderItem#new" do
    it "works" do
      get new_product_order_item_path(products(:tears).id)
      must_respond_with :success
    end
  end

  describe "OrderItem#edit" do
    it "works" do
      get edit_order_item_path(chocolate1.id)
      must_respond_with :success
    end
  end

  describe "OrderItem#create" do

    let(:order) { orders(:pending_order) }

    it "creates an OrderItem with valid data" do
      order_item_data = {
        order_item: {
          quantity: 1,
          order: order
        }
      }

      start_count = OrderItem.count
      post product_order_items_path(products(:tears).id), params: order_item_data

      must_redirect_to products_path
      flash[:result_text].must_equal "1 #{products(:tears).name} have been added to your order!"
      OrderItem.count.must_equal start_count + 1
    end

    it "renders bad_request and does not update the DB for missing data" do
      order_item_data = {
        order_item: {
          quantity: -1,
          order: order
        }
      }

      start_count = OrderItem.count
      post product_order_items_path(products(:tears).id), params: order_item_data

      flash[:result_text].must_equal "Error - products not added to your order"
      must_respond_with :bad_request
      OrderItem.count.must_equal start_count
    end

    it "renders 400 bad_request for bogus categories" do
      order_item_data = {
        order_item: {
          product: "",
          quantity: -1,
          order: order
        }
      }

      start_count = OrderItem.count
      post product_order_items_path(products(:tears).id), params: order_item_data
  flash[:result_text].must_equal "Error - products not added to your order"
      must_respond_with :bad_request
      OrderItem.count.must_equal start_count
  end
end

  describe "OrderItem#update" do

    it "allows order_item updates for an order with an 'incomplete' status" do
      #Arrange
      chocolate1.order.status.must_equal "incomplete"
      new_quantity = 3
      oi_update_data = {
        order_item: {
          quantity: new_quantity,
          product: chocolate1.product,
          order: chocolate1.order
        }
      }

      #Action
      patch order_item_path(chocolate1.id), params: oi_update_data

      #Assert
      must_respond_with :redirect
      must_redirect_to order_path(chocolate1.order.id)

      OrderItem.find(chocolate1.id).quantity.must_equal new_quantity

    end

    it "does not allow you to choose a product quantity greater than the number available" do
      product = chocolate1.product
      original_quantity= chocolate1.quantity

      oi_update_data = {
        order_item: {
          quantity: (product.quantity + 1),
          product: chocolate1.product,
          order: chocolate1.order
        }
      }

      #Action
      patch order_item_path(chocolate1.id), params: oi_update_data

      #Assert
      must_respond_with :bad_request
flash[:result_text].must_equal "Error: You must choose a quantity less than or equal to the available quantity (#{product.quantity})"
      OrderItem.find(chocolate1.id).quantity.must_equal original_quantity

    end

    it "must have a valid quantity to update" do

      invalid = [-1,0]
      original_quantity= chocolate1.quantity

      invalid.each do |num|

        oi_update_data = {
          order_item: {
            quantity: num,
            product: chocolate1.product,
            order: chocolate1.order
          }
        }

        patch order_item_path(chocolate1.id), params: oi_update_data

        must_respond_with :bad_request
        OrderItem.find(chocolate1.id).quantity.must_equal original_quantity
      end

    end

    it "does not allow order_item updates for an order with a 'paid' status" do
      #Arrange
      soap2.order.status.must_equal "paid"

      old_quantity = soap2.quantity
      new_quantity = 3
      oi_update_data = {
        order_item: {
          quantity: new_quantity,
          product: soap2.product,
          order: soap2.order
        }
      }
      #Action

      patch order_item_path(soap2.id), params: oi_update_data

      #Assert

      must_respond_with :redirect

      OrderItem.find_by_id(soap2.id).quantity.must_equal old_quantity

    end

  end

  describe "OrderItem#destroy" do
    let(:incomplete) {orders(:pending_order)}
    let(:paid) { orders(:paid_order) }

    let(:chocolate1) { order_items(:orderitem1) }
    let(:soap2) { order_items(:orderitem2) }


    it "only deletes an order_item from cart when order status is incomplete" do
      #Arrange
      chocolate1.order.status.must_equal "incomplete"
      #Action
      delete order_item_path(chocolate1.id)
      #Assert
      OrderItem.find_by(id: chocolate1.id).must_be_nil
      must_redirect_to order_path(incomplete.id)

    end

    it "cannot delete an order_item from cart when order status is paid" do
      #Arrange
      soap2.order.status.must_equal "paid"
      #Action
      delete order_item_path(soap2.id)
      #Assert
      OrderItem.find_by(id: soap2.id).must_equal soap2
      must_redirect_to order_path(paid.id)

    end
  end

  describe "OrderItem#mark_shipped" do

    let(:merchant) {users(:je)}
    let(:merchant_order_item) {order_items(:orderitem4)}

    it "ensures a paid order_item's default shipping status is: not shipped" do
      login(merchant)

      merchant_order_item.shipped.must_equal "not shipped"

    end

    it "changes order_item's shipping status to: shipped" do
      login(merchant)
      merchant_order_item.shipped.must_equal "not shipped"

      patch item_shipped_path(merchant_order_item.id)
      merchant_order_item.reload
      merchant_order_item.shipped.must_equal "shipped"
    end
  end
end
