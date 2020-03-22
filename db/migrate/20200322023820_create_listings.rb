class CreateListings < ActiveRecord::Migration[6.0]
  def change
    create_table :listings, id: :uuid do |t|
      t.string :name
      t.references :category, null: false, type: :uuid, foreign_key: { to_table: :classifications }
      t.references :subcategory, null: false, type: :uuid, foreign_key: { to_table: :classifications }
      t.string :street
      t.string :street_number
      t.string :internal_number
      t.string :postal_code
      t.string :district
      t.references :city, null: false, type: :uuid, foreign_key: true
      t.references :entity, null: false, type: :uuid, foreign_key: true
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.boolean :delivery_service
      t.boolean :carry_out
      t.boolean :online_store

      t.timestamps
    end
  end
end
