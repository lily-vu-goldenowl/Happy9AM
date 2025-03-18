require 'rails_helper'

RSpec.describe ScheduledEventJob, type: :job do
  describe '#perform' do
    let(:user) { instance_double(User, id: 1, timezone: 'Asia/Ho_Chi_Minh') }
    let(:event_type) { 'birthday' }
    let(:hour) { 9 }
    let(:strategy) { instance_double(Strategies::BirthdayStrategy, hour: hour) }
    let(:today) { Date.new(2023, 10, 25) }
    let(:event_date) { today }

    before do
      allow(EventStrategyFactory).to receive(:create_strategy).with(event_type, hour).and_return(strategy)
      allow(User).to receive(:find_each).and_yield(user)
      allow(Time).to receive(:now).and_return(Time.new(2023, 10, 25, 8, 0, 0, '+07:00'))
      allow(user).to receive(:next_event_date).with(event_type).and_return(event_date)
    end

    context 'when event_date is nil' do
      let(:event_date) { nil }

      it 'skips the user without scheduling any job' do
        expect(DeliverEventMessageJob).not_to receive(:perform_later)
        expect(DeliverEventMessageJob).not_to receive(:set)

        ScheduledEventJob.new.perform(event_type, hour)
      end
    end

    context 'when event_date is not today' do
      let(:event_date) { today + 1 }

      it 'skips the user without scheduling any job' do
        expect(DeliverEventMessageJob).not_to receive(:perform_later)
        expect(DeliverEventMessageJob).not_to receive(:set)

        ScheduledEventJob.new.perform(event_type, hour)
      end
    end

    context 'when event_date is today' do
      context 'when message has already been sent' do
        before do
          allow(strategy).to receive(:already_sent?).with(user, today).and_return(true)
        end

        it 'skips the user without scheduling any job' do
          expect(DeliverEventMessageJob).not_to receive(:perform_later)
          expect(DeliverEventMessageJob).not_to receive(:set)

          ScheduledEventJob.new.perform(event_type, hour)
        end
      end

      context 'when message has not been sent' do
        before do
          allow(strategy).to receive(:already_sent?).with(user, today).and_return(false)
        end

        context 'when current hour is greater than or equal to target hour' do
          before do
            allow(Time).to receive(:now).and_return(Time.new(2023, 10, 25, 10, 0, 0, '+07:00'))
          end

          it 'schedules the job to run immediately' do
            expect(DeliverEventMessageJob).to receive(:perform_later).with(user.id, event_type, hour)

            ScheduledEventJob.new.perform(event_type, hour)
          end
        end

        context 'when current hour is less than target hour' do
          let(:event_time) { Time.new(2023, 10, 25, 9, 0, 0, '+07:00') }

          before do
            allow(strategy).to receive(:calculate_event_time).with(today, user.timezone).and_return(event_time)
          end

          it 'schedules the job to run at the target time' do
            expect(DeliverEventMessageJob).to receive(:set).with(wait_until: event_time).and_return(DeliverEventMessageJob)
            expect(DeliverEventMessageJob).to receive(:perform_later).with(user.id, event_type, hour)

            ScheduledEventJob.new.perform(event_type, hour)
          end
        end
      end
    end
  end
end