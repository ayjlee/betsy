class Order < ApplicationRecord

  STATUS = ["incomplete", "paid", "complete"]

  has_many :order_items

  validates :status, presence: true, inclusion: { in: STATUS, allow_nil: false}

  def total_cost
    total = 0.0

    self.order_items.each do |item|
      product = Product.find_by_id(item.product_id)
      total += (product.price * item.quantity)
    end
    return total.round(2)
  end

  def self.by_user(user)
    if !User.all.include?(user)
      return []
    else

      user.order_items.map {|order_item| order_item.order }

    end

  end

  def inventory_check
    unavailable_items = []

    self.order_items.each do |item|
      if item.available?
        next
      else
        unavailable_items << item.product.name
      end
    end

    return unavailable_items
  end

  def inventory_adjust
    unavailable = self.inventory_check
    if unavailable.empty?
      self.order_items.each do |item|
        product = Product.find_by_id(item.product_id)
        product.quantity -= item.quantity
        product.save
      end
    else
      return false
    end
  end

  def self.by_status(status, orders)
    return orders.select {|ord| ord.status == status }
  end

end
