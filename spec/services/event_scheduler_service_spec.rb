require 'rails_helper'
require 'sidekiq/testing'
require 'sidekiq/api'

RSpec.describe EventSchedulerService, type: :service do
  let(:user) { instance_double(User, id: 1, timezone: 'Asia/Ho_Chi_Minh') }
  let(:strategy) { instance_double(Strategies::BirthdayStrategy, event_type: 'birthday', hour: 9) }
  let(:event_date) { Date.new(2023, 10, 25) }
  let(:event_time) { Time.new(2023, 10, 25, 9, 0, 0, '+07:00') }

  before do
    Sidekiq::Testing.disable!
    Sidekiq::ScheduledSet.new.clear
    DeliverEventMessageJob.set(wait_until: event_time).perform_later(user.id, strategy.event_type, strategy.hour)
  end

  describe '.schedule_all_events' do
    it 'calls schedule_event for each strategy' do
      allow(EventStrategyFactory).to receive(:all_strategies).and_return([strategy])
      expect(described_class).to receive(:schedule_event).with(user, strategy)

      described_class.schedule_all_events(user)
    end
  end

  describe '.reschedule_all_events' do
    it 'calls reschedule_event for each strategy' do
      allow(EventStrategyFactory).to receive(:all_strategies).and_return([strategy])
      expect(described_class).to receive(:reschedule_event).with(user, strategy)

      described_class.reschedule_all_events(user)
    end
  end

  describe '.cancel_all_events' do
    it 'calls cancel_event for each strategy' do
      allow(EventStrategyFactory).to receive(:all_strategies).and_return([strategy])
      expect(described_class).to receive(:cancel_event).with(user.id, strategy.event_type)

      described_class.cancel_all_events(user.id)
    end
  end

  describe '.schedule_event' do
    before do
      allow(user).to receive(:next_event_date).with(strategy.event_type).and_return(event_date)
      allow(strategy).to receive(:calculate_event_time).with(event_date, user.timezone).and_return(event_time)
    end

    context 'when event_date is present' do
      it 'schedules a DeliverEventMessageJob with the correct parameters' do
        expect(DeliverEventMessageJob).to receive(:set).with(wait_until: event_time).and_return(DeliverEventMessageJob)
        expect(DeliverEventMessageJob).to receive(:perform_later).with(user.id, strategy.event_type, strategy.hour)

        described_class.schedule_event(user, strategy)
      end
    end

    context 'when event_date is nil' do
      it 'does not schedule any job' do
        allow(user).to receive(:next_event_date).with(strategy.event_type).and_return(nil)
        expect(DeliverEventMessageJob).not_to receive(:set)

        described_class.schedule_event(user, strategy)
      end
    end
  end

  describe '.reschedule_event' do
    it 'calls cancel_event and schedule_event' do
      expect(described_class).to receive(:cancel_event).with(user.id, strategy.event_type)
      expect(described_class).to receive(:schedule_event).with(user, strategy)

      described_class.reschedule_event(user, strategy)
    end
  end
end
