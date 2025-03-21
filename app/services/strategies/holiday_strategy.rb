module Strategies
  class HolidayStrategy < BaseEventStrategy
    def initialize(hour = nil)
      super
      @event_type = 'holiday'
    end

    def scope_records
      User.all
    end

    def compose_message(user)
      "Happy holidays, #{user.full_name}!"
    end
  end
end
