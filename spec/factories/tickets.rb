FactoryBot.define do
  factory :ticket do
    company { nil }
    ticket_type { nil }
    reporter { nil }
    assignee { nil }
    priority { 1 }
    status { "MyString" }
    subject { "MyString" }
    description { "MyText" }
    custom_fields { "" }
    metadata { "" }
    closed_at { "2026-05-13 12:00:23" }
    due_at { "2026-05-13 12:00:23" }
    discarded_at { "2026-05-13 12:00:23" }
  end
end
