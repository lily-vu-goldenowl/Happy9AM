require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:birthday) }
    it { should validate_presence_of(:timezone) }
  end

  describe '.today_is_birthday' do
    let(:user) { create(:user, :birthday_today, timezone: 'America/New_York') }
    let(:other_user) { create(:user, :birthday_tomorrow) }

    it 'returns list user has birthday today' do
      expect(User.today_is_birthday).to include(user)
      expect(User.today_is_birthday).not_to include(other_user)
    end
  end

  describe '#full_name' do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns the correct full name' do
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe '#next_event_date' do
    let(:user) { create(:user, birthday: '2000-03-14', timezone: 'America/New_York') }

    it 'calculates the next birthday date correctly' do
      next_birthday = user.next_event_date('birthday')
      expect(next_birthday).to be_a(Date)
    end
  end
end
