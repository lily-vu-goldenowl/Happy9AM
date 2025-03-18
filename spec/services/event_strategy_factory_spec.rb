require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe EventStrategyFactory, type: :service do
  describe '.create_strategy' do
    context 'when event_type is birthday' do
      it 'returns a BirthdayStrategy instance' do
        strategy = described_class.create_strategy('birthday', 9)
        expect(strategy).to be_a(Strategies::BirthdayStrategy)
        expect(strategy.hour).to eq(9)
      end
    end

    context 'when event_type is holiday' do
      it 'returns a HolidayStrategy instance' do
        strategy = described_class.create_strategy('holiday', nil)
        expect(strategy).to be_a(Strategies::HolidayStrategy)
        expect(strategy.hour).to be_nil
      end
    end

    context 'when event_type is unknown' do
      it 'raises an ArgumentError' do
        expect { described_class.create_strategy('unknown') }.to raise_error(ArgumentError, /Unknown event type/)
      end
    end
  end

  describe '.all_strategies' do
    it 'returns an array of default strategies' do
      strategies = described_class.all_strategies
      expect(strategies).to all(be_a(Strategies::BaseEventStrategy))
      expect(strategies.size).to eq(1)
      expect(strategies.first).to be_a(Strategies::BirthdayStrategy)
      expect(strategies.first.hour).to eq(9)
    end
  end
end