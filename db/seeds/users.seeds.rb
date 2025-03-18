# db/seeds.rb

require 'faker'

# Clear existing users to avoid duplication
User.destroy_all

# Get today's and tomorrow's date
today = Date.today
tomorrow = today + 1

# Create 25 users with today's birthday
25.times do
  FactoryBot.create(:user, birthday: today)
end

# Create 25 users with tomorrow's birthday
25.times do
  FactoryBot.create(:user, birthday: tomorrow)
end

puts "Seeded 50 users with birthdays on #{today} and #{tomorrow}"
