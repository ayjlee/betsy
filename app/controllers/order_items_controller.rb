class OrderItemsController < ApplicationController

  def new
    # try to get order out of session and if not there create one and put it in the session
    @order_item = OrderItem.new
    @product = Product.find_by(id: params[:product_id])
  end

  def create
    if session[:order_id] == nil
      @order = Order.new
      @order.save
      session[:order_id] = @order.id
    else
      @order = Order.find_by(id: session[:order_id])
    end
    @product = Product.find_by(id: params[:product_id])
    @order_item = OrderItem.new(order_item_params)
    @order_item.product_id = @product.id
    @order_item.order_id = @order.id

    # @order = current_order
    if @order_item.save
      flash[:status] = :success
      flash[:result_text] = "#{@order_item.quantity} #{@order_item.product.name} have been added to your order!"
      redirect_to products_path
    else
      # binding.pry
      flash[:status] = :error
      flash[:message] = "Error - products not added to your order"
      render :new
    end
    # session[:order_id] = @order.id
  end

  def edit
    @order_item = OrderItem.find_by(id: params[:id])
    @product = @order_item.product
  end

  def update
    @order_item = OrderItem.find_by(id: params[:id])
    @order = @order_item.order

    if @order.status == "incomplete"
      @order_item.update_attributes(order_item_params)

      if @order_item.save
        flash[:status] = :success
        flash[:result_text] = "Order Item has updated."
        redirect_to order_path(@order.id)
      else
        flash[:status] = :failure
        flash[:result_text] = "Error: Could not update your order_item.}"
        flash[:messages] = @review.errors.messages
        render :edit, status: :bad_request
      end
    else
      flash[:status] = :failure
      flash[:result_text] = "Your order cannot be edited as its status is already paid."
      redirect_to root_path
    end

  end

  def destroy
    @order = current_order
    @order_item = @order.order_items.find(params[:id])
    @order_item.destroy
    @order_items = @order.order_items
  end

  private
  def order_item_params
    params.require(:order_item).permit(:quantity, :product_id)
  end
end
