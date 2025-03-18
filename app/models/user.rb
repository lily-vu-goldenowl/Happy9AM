class User < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :birthday, presence: true
  validates :timezone, presence: true

  has_many :message_logs, dependent: :destroy

  scope :today_is_birthday, ->() {
    today = Time.current
    where("EXTRACT(MONTH FROM birthday) = ? AND EXTRACT(DAY FROM birthday) = ?", today.month, today.day)
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def next_event_date(event_type)
    case event_type
    when 'birthday'
      next_birthday_date
    when 'holiday'
      # Placeholder for future implementation
      nil
    else
      raise ArgumentError, "Unknown event type: #{event_type}"
    end
  end

  private

  def next_birthday_date
    today = Time.now.in_time_zone(timezone).to_date
    birthday_this_year = Date.new(today.year, birthday.month, birthday.day)

    if birthday_this_year < today
      birthday_this_year = Date.new(today.year + 1, birthday.month, birthday.day)
    end

    birthday_this_year
  end
end
