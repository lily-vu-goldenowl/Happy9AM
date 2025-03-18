class MessageLog < ApplicationRecord
  MESSAGE_LOG_STATUSES = %w[sent failed]

  belongs_to :user
  validates :event_type, presence: true
  validates :status, presence: true, inclusion: { in: MESSAGE_LOG_STATUSES }

  scope :sent, -> { where(status: 'sent') }
  scope :failed, -> { where(status: 'failed') }
  scope :for_event, ->(event_type) { where(event_type: event_type) }

  def self.already_sent?(user_id, event_type, reference_date)
    sent.for_event(event_type)
        .where(user_id: user_id)
        .where('DATE(sent_at) = ?', reference_date)
        .exists?
  end
end
