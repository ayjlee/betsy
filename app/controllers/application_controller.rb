class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  before_action :current_order

  def render_404
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

  def current_order
    if session[:order_id] == nil
      create_new_order
    else

      @order = Order.find_by(id: session[:order_id])
      if @order
        if @order.status == "paid"
          create_new_order
        end
        return
      else
        create_new_order
      end
    end
  end

  def create_new_order
    @order = Order.new
    @order.status = "incomplete"
    @order.save
    session[:order_id] = @order.id
    session[:order_items_count] = 0
  end
end
