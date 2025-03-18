FactoryBot.define do
  factory :message_log do
    association :user
    event_type { ['birthday', 'holiday'].sample}
    sent_at { nil }

    trait :birthday_event_type do
      event_type { 'birthday' }
    end

    trait :sent do
      status { 'sent' }
      sent_at { Date.today }
    end

    trait :failed do
      status { 'failed' }
    end
  end
end
