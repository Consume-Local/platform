class Listing < ApplicationRecord
  belongs_to :category
  belongs_to :subcategory
  belongs_to :city
  belongs_to :entity
  belongs_to :user
end
