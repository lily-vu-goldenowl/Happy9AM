class DeliverEventMessageJob < ApplicationJob
  queue_as :event_processing

  discard_on ActiveJob::DeserializationError

  def perform(user_id, event_type, hour = nil)
    return if (user = User.find_by(id: user_id)).nil?

    strategy = EventStrategyFactory.create_strategy(event_type, hour)

    event_date = user.next_event_date(event_type)
    return if event_date.nil?

    today = Time.now.in_time_zone(user.timezone).to_date

    if event_date.present? && event_date == today
      unless strategy.already_sent?(user, today)
        success = strategy.send_message(user)
      end
    end

    # Schedule the next occurrence
    EventSchedulerService.schedule_event(user, strategy)
  end
end
