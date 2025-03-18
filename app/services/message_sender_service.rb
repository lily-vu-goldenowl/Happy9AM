require 'net/http'

class MessageSenderService
  HOOKBIN_URL = ENV.fetch('HOOKBIN_URL')

  def self.send_message(user, message_text, event_type)
    new.send_message(user, message_text, event_type)
  end

  def send_message(user, message_text, event_type)
    success = false
    message_log_attributes = { user_id: user.id, event_type: event_type }

    uri = URI(HOOKBIN_URL)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

    req.body = {
      message: message_text
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    if response.is_a?(Net::HTTPSuccess)
      success = true
      message_log_attributes.merge!(
        status: 'sent',
        sent_at: Time.current
      )
    else
      message_log_attributes.merge!(
        status: 'failed',
        error_message: "HTTP Error: #{response.code}"
      )
    end

    MessageLog.create!(message_log_attributes)
    return success
  end
end
