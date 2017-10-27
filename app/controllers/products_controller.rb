
class ProductsController < ApplicationController
  before_action :find_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.find_instock
  end

  def show
    render_404 unless @product
  end
  
  def new
    @product = Product.new
  end

  def create

    categories = Category.clean_up(params[:product][:categories])

    @product= Product.new product_params
    @product.user_id = session[:user_id]
    categories.each do |category|
      @product.categories << category
    end

    if @product.save
      flash[:status] = :success
      redirect_to product_path(@product.id)
    else
      flash[:status] = :failure
      flash.now[:result_text] = "Error: Product was not added"
      render :new
    end

  end

  def edit
    render_404 unless @product
  end

  def update
    categories = Category.clean_up(params[:product][:categories])

    @product.update_attributes(product_params)
    categories.each do |category|
      @product.categories << category
    end

    if @product.save
      flash[:status] = :success
      flash[:result_text] = "Successfully updated #{@product.name}"
      redirect_to product_path(@product.id)
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not update #{@product.name}"
      flash.now[:messages] = @product.errors.messages
      render :edit, status: :not_found
    end
  end

  def destroy
    @product.destroy
    flash[:status] = :success
    flash[:result_text] = "Successfully destroyed #{@product.name}"
    redirect_to root_path
  end

  def by_category
    @products_by_category = Product.to_category_hash
  end

  def by_merchant
    @products_by_merchant =  Product.to_merchant_hash
  end

  private

  def find_product
    @product = Product.find_by_id(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :quantity, :stock, :photo)
  end

end
