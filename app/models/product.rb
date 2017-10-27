class Product < ApplicationRecord

  STOCK = ["In Stock", "Out of Stock"]
  has_attached_file :photo,
  :default_url => 'glitzy_default.png',
  styles: {
    thumb: '100x100>',
    square: '200x200>',
    medium: '300x300>',
    large: '400x400>'
  }

  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  has_many :reviews
  has_many :order_items
  belongs_to :user

  has_and_belongs_to_many :categories

  validates :name, presence: true
  validates_uniqueness_of :name, scope: [:category]
  validates :price, presence: true, numericality: true,
  :format => { :with => /^\d{1,4}(\.\d{0,2})?$/, multiline: true }
  validates :quantity, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def self.to_category_hash
    data = {}
    Category.all.each do |cat|
      data[cat.name] = by_category(cat)
    end
    return data
  end

  def self.to_merchant_hash
    data = {}
    merchants_with_products= (User.all).select{|merchant| merchant.products.count > 0}

    merchants_with_products.each do |merchant|
      data[merchant.name] = by_merchant(merchant)
    end
    return data
  end

  def self.by_category(category)
    if !Category.all.include?(category)
      return []
    else
      return category.products.select {|prod| prod.instock }
    end
  end

  def self.by_merchant(merchant)
    if !User.all.include?(merchant)
      return []
    else
      return merchant.products.select {|prod| prod.instock }
    end
  end


  def avg_rating
    if (self.reviews).count > 0
      product_reviews = self.reviews
      sum_ratings = 0.0
      product_reviews.each do |review|
        sum_ratings += review.rating
      end
      avg = sum_ratings/(product_reviews.count)
      return avg
    else
      return 0
    end
  end

  def instock
    if self.quantity > 0 && self.stock == "In Stock"
      return true
    else
      return false
    end
  end

  def self.find_instock
    @products = []
    Product.all.each do |prod|
      if prod.quantity > 0 && prod.stock == "In Stock"
        @products << prod
      end
    end
    return @products
  end

end
