FactoryBot.define do
  factory :ticket_type do
    company { nil }
    key { "MyString" }
    name { "MyString" }
    description { "MyText" }
    workflow { "" }
    custom_fields_schema { "" }
    default_priority { 1 }
    color { "MyString" }
    active { false }
    discarded_at { "2026-05-13 12:00:18" }
  end
end
