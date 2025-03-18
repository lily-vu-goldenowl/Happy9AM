namespace :sidekiq do
  desc "Enqueue ScheduledEventJob to process birthday events immediately"
  task schedule_birthdays: :environment do
    ScheduledEventJob.perform_async('birthday', 9)  # Ensure birthday jobs are enqueued for 9 AM
    puts "✅ ScheduledEventJob enqueued for processing birthdays!"
  end

  desc "Send event messages for all users with today's events (e.g., birthdays)"
  task send_event_messages: :environment do
    today = Date.today

    User.today_is_birthday.find_each do |user|
      next unless user.next_event_date('birthday') == today

      unless DeliverEventMessageJob.already_sent?(user.id, 'birthday', today)
        DeliverEventMessageJob.perform_async(user.id, 'birthday', 9)  # Enqueue job to send message
        puts "🎉 Scheduled birthday message for #{user.full_name}"
      end
    end
  end
end
