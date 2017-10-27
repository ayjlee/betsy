require "test_helper"

describe OrderItem do
  let(:item1) {order_items(:orderitem1)}
  let(:order1) {orders(:pending_order)}
  let(:product) { products(:soap)}

  describe 'relationships' do
    it "has a product" do
      item1.must_respond_to :product
      item1.must_be_kind_of OrderItem
      item1.product.must_be_kind_of Product
    end

    it "has an order" do
      item1.must_respond_to :order
      item1.order.must_equal order1
    end

  end

  describe 'validations' do
    it "requires a quantity" do
      item_no_quantity = OrderItem.new
      item_no_quantity.valid?.must_equal false
      item_no_quantity.errors.messages.must_include :quantity
    end

    it "requires that quantity is a positive integer " do
      item1.quantity.must_be_kind_of Integer
      item1.quantity.must_be :>, 0
      item1.quantity.must_equal 1
    end

    it "accepts valid quantity" do
      valid_quantity = [1, 20, 30, 4, 5]
      valid_quantity.each do |quantity|
        valid_orderitem = OrderItem.new(product_id: product.id, order_id: order1.id, quantity: quantity)
        valid_orderitem.valid?.must_equal true
      end
    end

    it "rejects invalid quantity" do
      invalid_quantity = [-1, 0, 'one', nil]
      invalid_quantity.each do |quantity|
        invalid_orderitem = OrderItem.new(product_id: product.id, order_id: order1.id, quantity: quantity)
        invalid_orderitem.valid?.must_equal false
        invalid_orderitem.errors.messages.must_include :quantity
      end
    end
  end

end
