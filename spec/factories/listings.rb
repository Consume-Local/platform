FactoryBot.define do
  factory :listing do
    name { "MyString" }
    category { nil }
    subcategory { nil }
    street { "MyString" }
    street_number { "MyString" }
    internal_number { "MyString" }
    postal_code { "MyString" }
    district { "MyString" }
    city { nil }
    entity { nil }
    user { nil }
    delivery_service { false }
    carry_out { false }
    online_store { false }
  end
end
