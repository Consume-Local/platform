class CreateJoinTableCategorySubcategory < ActiveRecord::Migration[6.0]
  def change
    create_join_table :categories, :subcategories do |t|
      t.index [:category_id, :subcategory_id] , name: 'category_subcat_id'
      t.index [:subcategory_id, :category_id], name: 'subcat_category_id'
    end
  end
end
