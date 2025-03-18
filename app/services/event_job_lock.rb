class EventJobLock
  def self.redis
    @redis ||= Redis.new
  end

  def self.redis_key(event_type, user_id)
    "event_job:#{event_type}:#{user_id}:#{Time.now.in_time_zone.to_date}"
  end

  def self.lock(event_type, user_id)
    redis.set(redis_key(event_type, user_id), 1, ex: 24.hours, nx: true)
  end

  def self.unlock(event_type, user_id)
    redis.del(redis_key(event_type, user_id))
  end
end
