require "test_helper"

describe Product do

  let(:product) { products(:soap)}

  describe "relations" do
    it "has a user" do
      product.must_respond_to :user
      product.must_be_kind_of Product
      product.user.must_be_kind_of User
    end

    it "has a category" do
      prod = products(:tears)
      prod.must_respond_to :categories
    end

    it "has a list (can have many) reviews" do
      product.must_respond_to :reviews
      product.reviews.each do |review|
        review.must_be_kind_of Review
      end
    end

    it "has a list (can have many) order items" do
      product.must_respond_to :order_items
      product.order_items.each do |item|
        item.must_be_kind_of OrderItem
      end
    end
  end

  describe "validations" do
    let(:tanja) { users(:tanja) }

    it "allows valid categories" do

    end

    it "rejects not created categories" do

    end

    it "requires a price greater than 0" do
      product.price.must_be_kind_of BigDecimal
      product.price.must_be :>, 0
    end

    it "accepts valid price" do
      valid_price = [1, 5.00, 200.99]
      valid_price.each do |price|
        valid_product = Product.new(category: 'food', name: 'good-food', price: price, quantity: 5, user: tanja)
        valid_product.valid?.must_equal true
      end
    end

    it "rejects invalid price" do
      invalid_price = [-1.00, nil, "1 dollar"]
      invalid_price.each do |price|
        invalid_product = Product.new(category: 'food', name: 'cool-food', price: price, quantity: 5, user: tanja)
        invalid_product.valid?.must_equal false
        invalid_product.errors.messages.must_include :price
      end
    end

    it "requires a name" do
      product = Product.new(category: 'food', price: 10.00, quantity: 5, user: tanja)
      product.valid?.must_equal false
      product.errors.messages.must_include :name
    end

    it "requires unique names w/in categories" do
      category = 'food'
      name = 'test name'
      product1 = Product.new(name: name, category: category, price: 10.00, quantity: 5, user: tanja)
      product1.save!

      product2 = Product.new(name: name, category: category, price: 10.00, quantity: 5, user: tanja)
      product2.valid?.must_equal false
      # product2.errors.messages.must_include :name
    end

    it "does not require a unique name if the category is different" do
      name = 'test name'
      product1 = Product.new(name: name, category: 'food', price: 10.00, quantity: 5, user: tanja)
      product1.save!

      product2 = Product.new(name: name, category: 'cosmetics', price: 10.00, quantity: 5, user: tanja)
      product2.valid?.must_equal true
    end
  end

  describe "custom model methods " do

    describe "self.by_category(category)" do
      let(:transportation) { categories(:transportation) }
      let(:weekend_yacht) {products(:yacht)}
      let(:cosmetics_cat) { categories(:cosmetics)}

      it "returns a collection of Products of the appropriate category" do
        weekend_yacht.categories << transportation
        Product.by_category(transportation).count.must_equal 1
        Product.by_category(transportation)[0].must_be_kind_of Product

        ###REFACTOR tests below ####
        cosmetics = Product.where(category: "cosmetics")

        cosmetics.each do |cosmetic|
          cosmetic.categories << cosmetics_cat
        end

        Product.by_category(cosmetics_cat).must_be_kind_of Enumerable

        Product.by_category(cosmetics_cat).count.must_equal 3

      end

      it "will not error out if there are no products of that category" do

        Product.by_category("bamboozles").count.must_equal 0
      end

    end

    describe "self.by_merchant(merchant)" do
      let(:user) {users(:bubbles)}
      it "returns an array of products by the given merchant" do
        Product.by_merchant(user).count.must_equal user.products.count

        user.products.each do |product|
          Product.by_merchant(user).must_include product
        end

        Product.by_merchant(users(:buttercup)).count.must_equal 2

      end

      it "will not error out if there are no products from that merchant" do
        Product.by_category("bamboozled").count.must_equal 0
      end

    end

    describe "self.to_merchant_hash method" do
      it "returns a hash with user names as keys and product arrays as values" do
        merchant_hash = Product.to_merchant_hash

        merchant_hash.must_be_kind_of Hash
        merchant_hash.keys.count.must_equal 4
      end
    end

    describe "Product#avg_rating" do
      let(:soap_review1) {reviews(:one)}
      let(:soap_review2) {reviews(:two)}

      let(:product_no_review) {products(:chocolate)}

      it "returns correct average rating" do
        product.avg_rating.must_equal 3
      end

      it "returns 0 rating for products with no review" do
        product_no_review.avg_rating.must_equal 0
      end

    end

    describe "self.to_category_hash method" do
      it "returns a hash with categories as keys and product arrays as values" do
        category_hash = Product.to_category_hash

        category_hash.must_be_kind_of Hash
        category_hash.keys.count.must_equal 4
      end
    end

    describe "Product#instock" do

      let(:product_quant0) { products(:candy1)}
      let(:outstock_product) { products(:candy2)}

      it "returns true if product quantity is greater than 0 and stock is: In Stock" do
        product.instock.must_equal true
      end

      it "returns false if product is quantity is 0" do
        product_quant0.instock.must_equal false
      end

      it "returns false if product is stock is: Out of Stock" do
        outstock_product.instock.must_equal false
      end
    end

  end
end
