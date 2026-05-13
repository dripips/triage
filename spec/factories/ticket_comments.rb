FactoryBot.define do
  factory :ticket_comment do
    ticket { nil }
    author { nil }
    body { "MyText" }
    internal { false }
    discarded_at { "2026-05-13 12:00:28" }
  end
end
