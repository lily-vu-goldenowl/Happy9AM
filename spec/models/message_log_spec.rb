require 'rails_helper'

RSpec.describe MessageLog, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:event_type) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[sent failed]) }
  end

  describe '.already_sent?' do
    let!(:user) { create(:user, birthday: '1990-03-14', timezone: 'UTC') }
    let!(:message_log) { create(:message_log, :birthday_event_type, :sent, user:) }

    it 'returns true if a message was already sent on the same day' do
      expect(MessageLog.already_sent?(user.id, 'birthday', Date.today)).to be true
    end

    it 'returns false if no message was sent on the same day' do
      message_log.update!(status: 'failed')
      expect(MessageLog.already_sent?(user.id, 'birthday', Date.today)).to be false
    end
  end
end
