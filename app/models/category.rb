class Category < ApplicationRecord
  has_and_belongs_to_many :products

  validates :name, presence: true, uniqueness: true

  def self.clean_up(params)
    categories = params.map do |c|
      Category.find_by(id: c)
    end.compact
  end
  
end
