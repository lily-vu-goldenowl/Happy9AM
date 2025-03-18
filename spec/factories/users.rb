FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthday { Faker::Date.birthday }
    timezone { ["Europe/London", "Australia/Sydney"].sample }

    trait :birthday_today do
      birthday { Date.today - 30.years }
    end

    trait :birthday_tomorrow do
      birthday { Date.today + 1.days }
    end
  end
end
