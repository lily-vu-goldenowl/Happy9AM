module Strategies
  class BirthdayStrategy < BaseEventStrategy
    def initialize(hour = 9)
      super
      @event_type = 'birthday'
    end

    def scope_records
      User.today_is_birthday
    end

    def compose_message(user)
      "Hey, #{user.full_name} it's your birthday!"
    end
  end
end
