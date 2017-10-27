class CategoriesController < ApplicationController
  before_action :find_user,:authenticate

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = "New #{@category.name} category has been successfully created"
      redirect_to user_account_path(@login_user.id)
    else
      flash[:error] = "Category could not be created"
      @category.errors.messages
      render 'new'
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
