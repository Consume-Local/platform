# frozen_string_literal: true

#
# A Subcategory is the 2nd level of classification for a listing 
#
class Subcategory < Classification
  has_and_belongs_to_many :categories, join_table: 'categories_subcategories'
end
