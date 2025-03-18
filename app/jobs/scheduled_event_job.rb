class ScheduledEventJob
  include Sidekiq::Job
  sidekiq_options queue: :event_schedulers

  def perform(event_type, hour = nil)
    strategy = EventStrategyFactory.create_strategy(event_type, hour)

    User.today_is_birthday.find_each do |user|
      event_date = user.next_event_date(event_type)
      next if event_date.nil?

      today = Time.now.in_time_zone(user.timezone).to_date
      event_today = event_date == today

      if event_today && !strategy.already_sent?(user, today)
        # *IMPORTANT: Ensure this job is only enqueued once per user per day.
        next unless EventJobLock.lock(event_type, user.id)

        current_time = Time.now.in_time_zone(user.timezone)
        target_hour = hour || current_time.hour

        if current_time.hour >= target_hour
          DeliverEventMessageJob.perform_later(user.id, event_type, hour)
        else
          event_time = strategy.calculate_event_time(today, user.timezone)
          DeliverEventMessageJob.set(wait_until: event_time).perform_later(user.id, event_type, hour)
        end
      end
    end
  end
end
