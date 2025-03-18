class EventStrategyFactory
  def self.create_strategy(event_type, hour = nil)
    case event_type
    when 'birthday'
      Strategies::BirthdayStrategy.new(hour)
    when 'holiday'
      Strategies::HolidayStrategy.new(hour)
    else
      raise ArgumentError, "Unknown event type: #{event_type}"
    end
  end

  def self.all_strategies
    [
      Strategies::BirthdayStrategy.new(9), # Default birthday at 9 AM
    # Add more strategies here as they are implemented
    ]
  end
end