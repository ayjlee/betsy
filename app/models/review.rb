class Review < ApplicationRecord
  belongs_to :product
  
  validates :rating, presence: true, numericality: true

  validates_inclusion_of :rating, in: 1..5

end
