class ProductsController < ApplicationController
  before_action :find_product, only: [:show, :edit, :update, :destroy]

  # before_action :authenticate, except: [:index, :show]

  def index
    @products = find_instock
  end

  def show
    render_404 unless @product
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user_id = session[:user_id]

    id = @product.category.to_i
    cat = Category.find_by_id(id)
    @product.categories << cat

    if @product.save
      flash[:status] = :success
      redirect_to product_path(@product.id)
    else
      flash[:status] = :failure
      flash.now[:result_text] = "Error: You must be logged in to add a product!"
      render :new
    end
  end

  def edit
    render_404 unless @product
  end

  def update
    @product.update_attributes(product_params)

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
    # @products_by_merchant = Product.to_merchant_hash
   #placeholder for now


    # @products = find_instock

    @products_by_merchant =  Product.to_merchant_hash

  end


  private

  def find_product
    @product = Product.find_by_id(params[:id])
  end

  def product_params
    params.require(:product).permit(:category, :name, :description, :price, :quantity, :stock, :photo)
  end

  def find_instock
    @products = []
    Product.all.each do |prod|
      if prod.quantity > 0 && prod.stock == "In Stock"
        @products << prod
      end
    end
    return @products
  end

end
