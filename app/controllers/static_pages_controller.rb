class StaticPagesController < ApplicationController
  def home
    @showcase = Product.find_instock.sample(3)
  end
end
