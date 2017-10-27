class User < ApplicationRecord
  has_many :reviews
  has_many :products
  has_many :order_items, through: :products

  validates :uid, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true
  validates :provider, presence: true, inclusion: { in: %w(github) }

  def total_revenue_by_status(status)
    @order_items = self.order_items
    @revenue = 0.0
    @order_items.each do |item|
      if item.order.status == status
        @revenue += item.quantity * item.product.price
      end
    end
    return @revenue
  end

  def total_revenue
    @total_revenue = 0.0

    statuses = Order::STATUS
    statuses.each do |status|
      @total_revenue += self.total_revenue_by_status(status)
    end
    return @total_revenue
  end

  def user_orders
    self.order_items.map {|order_item| order_item.order}
  end

end
