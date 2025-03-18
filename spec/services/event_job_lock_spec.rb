require 'rails_helper'
require 'mock_redis'

RSpec.describe EventJobLock do
  let(:redis) { MockRedis.new }
  let(:event_type) { 'test_event' }
  let(:user_id) { 123 }
  let(:date) { Time.now.in_time_zone.to_date }
  let(:redis_key) { "event_job:#{event_type}:#{user_id}:#{date}" }

  before do
    allow(EventJobLock).to receive(:redis).and_return(redis)
  end

  describe '.redis_key' do
    it 'returns the correct redis key format' do
      expect(EventJobLock.redis_key(event_type, user_id)).to eq(redis_key)
    end
  end

  describe '.lock' do
    it 'sets a key in Redis with expiration and NX option' do
      expect(redis).to receive(:set).with(redis_key, 1, ex: 24.hours, nx: true)
      EventJobLock.lock(event_type, user_id)
    end
  end

  describe '.unlock' do
    it 'deletes the key from Redis' do
      redis.set(redis_key, 1)
      expect(redis.get(redis_key)).to eq('1')

      EventJobLock.unlock(event_type, user_id)
      expect(redis.get(redis_key)).to be_nil
    end
  end
end
