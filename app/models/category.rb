class Category < Classification
  has_many :projects, inverse_of: :category
  has_and_belongs_to_many :subcategories, join_table: 'categories_subcategories'
end
