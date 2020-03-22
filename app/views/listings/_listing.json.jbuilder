json.extract! listing, :id, :name, :category_id, :subcategory_id, :street, :street_number, :internal_number, :postal_code, :district, :city_id, :entity_id, :user_id, :delivery_service, :carry_out, :online_store, :created_at, :updated_at
json.url listing_url(listing, format: :json)
