class EventSchedulerService
  class << self
    def schedule_all_events(user)
      EventStrategyFactory.all_strategies.each do |strategy|
        schedule_event(user, strategy)
      end
    end

    def reschedule_all_events(user)
      EventStrategyFactory.all_strategies.each do |strategy|
        reschedule_event(user, strategy)
      end
    end

    def cancel_all_events(user_id)
      EventStrategyFactory.all_strategies.each do |strategy|
        cancel_event(user_id, strategy.event_type)
      end
    end

    def schedule_event(user, strategy)
      event_date = user.next_event_date(strategy.event_type)
      return if event_date.nil?

      event_time = strategy.calculate_event_time(event_date, user.timezone)
      DeliverEventMessageJob.set(wait_until: event_time).perform_later(user.id, strategy.event_type, strategy.hour)
    end

    def reschedule_event(user, strategy)
      cancel_event(user.id, strategy.event_type)
      schedule_event(user, strategy)
    end

    def cancel_event(user_id, event_type)
      queue = Sidekiq::ScheduledSet.new
      puts "Before cancel: #{queue.size} jobs"

      queue.each do |job|
        puts "Job: #{job.args.inspect}"
        if job.klass == "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper" &&
          job.args[0]["job_class"] == "DeliverEventMessageJob" &&
          job.args[0]["arguments"][0] == user_id &&
          job.args[0]["arguments"][1] == event_type
          puts "Deleting job: #{job.args.inspect}"
          job.delete
        end
      end
      EventJobLock.unlock(event_type, user_id) # Allow re-enqueuing if necessary
      puts "After cancel: #{Sidekiq::ScheduledSet.new.size} jobs"
    end
  end
end
