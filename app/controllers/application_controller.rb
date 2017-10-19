class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: supposedly this will actually render a 404 page in production
    render file: "#{Rails.root}/public/404.html" , status: :not_found
  end

  private
  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  def authenticate
    unless session[:user_id]
      redirect_to root_path
    end
  end

  def find_order
    #### Order: new order is created with default status :PENDING
    ### order is complete when status is changed to :PAID
    ####
    if @login_user
      #@login_user.orders.where(order_status: :PENDING)
    else
      # @order = Order.new
    end

  end

  def current_order
    if !session[:order_id].nil?
      Order.find(session[:order_id])
    else
      Order.new
    end
  end

end
