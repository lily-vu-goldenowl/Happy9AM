module Strategies
  class BaseEventStrategy
    attr_reader :event_type, :hour

    def initialize(hour = nil)
      @hour = hour
    end

    def calculate_event_time(event_date, timezone)
      return nil if event_date.nil?

      if @hour.nil?
        # If no specific hour is provided, use current time
        Time.now.in_time_zone(timezone).change(
          year: event_date.year,
          month: event_date.month,
          day: event_date.day
        )
      else
        # Set time to the specified hour
        Time.new(
          event_date.year,
          event_date.month,
          event_date.day,
          @hour, 0, 0,
          ActiveSupport::TimeZone.new(timezone).formatted_offset
        )
      end
    end

    def scope_records
      raise NotImplementedError, "Subclasses must implement this method"
    end

    def compose_message(user)
      raise NotImplementedError, "Subclasses must implement this method"
    end

    def send_message(user)
      MessageSenderService.send_message(user, compose_message(user), event_type)
    end

    def already_sent?(user, date)
      MessageLog.already_sent?(user.id, event_type, date)
    end
  end
end
