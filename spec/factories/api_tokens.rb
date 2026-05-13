FactoryBot.define do
  factory :api_token do
    user { nil }
    name { "MyString" }
    token_digest { "MyString" }
    token_prefix { "MyString" }
    last_used_at { "2026-05-13 11:40:45" }
    expires_at { "2026-05-13 11:40:45" }
  end
end
