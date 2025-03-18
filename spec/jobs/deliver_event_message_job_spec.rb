require 'rails_helper'

RSpec.describe DeliverEventMessageJob, type: :job do
  describe '#perform' do
    let(:user) { instance_double(User, id: 1, timezone: 'Asia/Ho_Chi_Minh') }
    let(:event_type) { 'birthday' }
    let(:hour) { 9 }
    let(:strategy) { instance_double(Strategies::BirthdayStrategy, hour: hour) }
    let(:today) { Date.new(2023, 10, 25) }
    let(:event_date) { today }

    before do
      allow(User).to receive(:find_by).with(id: user.id).and_return(user)
      allow(EventStrategyFactory).to receive(:create_strategy).with(event_type, hour).and_return(strategy)
      allow(Time).to receive(:now).and_return(Time.new(2023, 10, 25, 8, 0, 0, '+07:00'))
      allow(user).to receive(:next_event_date).with(event_type).and_return(event_date)
    end

    context 'when user is not found' do
      it 'returns early without doing anything' do
        allow(User).to receive(:find_by).with(id: user.id).and_return(nil)

        expect(EventStrategyFactory).not_to receive(:create_strategy)
        expect(EventSchedulerService).not_to receive(:schedule_event)

        DeliverEventMessageJob.new.perform(user.id, event_type, hour)
      end
    end

    context 'when user is found' do
      context 'when event_date is not today' do
        let(:event_date) { today + 1 }

        it 'does not send message but schedules the next event' do
          expect(strategy).not_to receive(:already_sent?)
          expect(strategy).not_to receive(:send_message)
          expect(EventSchedulerService).to receive(:schedule_event).with(user, strategy)

          DeliverEventMessageJob.new.perform(user.id, event_type, hour)
        end
      end

      context 'when event_date is today' do
        context 'when message has already been sent' do
          before do
            allow(strategy).to receive(:already_sent?).with(user, today).and_return(true)
          end

          it 'does not send message but schedules the next event' do
            expect(strategy).not_to receive(:send_message)
            expect(EventSchedulerService).to receive(:schedule_event).with(user, strategy)

            DeliverEventMessageJob.new.perform(user.id, event_type, hour)
          end
        end

        context 'when message has not been sent' do
          before do
            allow(strategy).to receive(:already_sent?).with(user, today).and_return(false)
          end

          it 'sends message and schedules the next event' do
            expect(strategy).to receive(:send_message).with(user)
            expect(EventSchedulerService).to receive(:schedule_event).with(user, strategy)

            DeliverEventMessageJob.new.perform(user.id, event_type, hour)
          end
        end
      end
    end

    context 'when event_date is nil' do
      let(:event_date) { nil }

      it 'does not send message and does not schedule the next event' do
        expect(strategy).not_to receive(:already_sent?)
        expect(strategy).not_to receive(:send_message)
        expect(EventSchedulerService).not_to receive(:schedule_event)

        DeliverEventMessageJob.new.perform(user.id, event_type, hour)
      end
    end
  end
end