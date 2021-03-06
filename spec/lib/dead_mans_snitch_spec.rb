# frozen_string_literal: true

require 'spec_helper'
require 'dead_mans_snitch'

describe DeadMansSnitch do
  let(:snitch_id) { 'WRNZLBRNFT' }

  describe '.report' do
    subject(:report) { described_class.report snitch_id }

    context 'when passed a snitch_id' do
      context 'when remote accepts the message' do
        before do
          stub_request(:post, "https://nosnch.in/#{snitch_id}")
            .to_return(status: 202, body: 'Got it, thanks!')
        end

        it 'returns http response' do
          expect(report.code).to eq('202')
        end
      end

      context 'when remote returns an error' do
        before do
          stub_request(:post, "https://nosnch.in/#{snitch_id}")
            .to_return(status: 400, body: 'Bad Snitch')
        end

        it 'returns http response' do
          expect(report.code).to eq('400')
        end
      end

      context 'when Net::HTTP throws an error' do
        it 'swallows the error' do
          expect_any_instance_of(Net::HTTP).to receive(:request) # rubocop:disable RSpec/AnyInstance
            .and_raise(Timeout::Error)
          expect { report }.not_to raise_error
        end

        it { is_expected.to be_falsey }
      end
    end

    context 'when passed nil as snitch_id' do
      let(:snitch_id) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when passed empty string as snitch_id' do
      let(:snitch_id) { '' }

      it { is_expected.to be_falsey }
    end
  end

  describe '.report_with_time' do
    let(:block) { nil }

    subject(:with_time) { described_class.report_with_time(snitch_id, &block) }

    context 'when no block was passed' do
      specify { expect { with_time }.to raise_error(LocalJumpError) }
    end

    context 'when a block was passed' do
      let(:block) { -> { 'result message' } }

      it 'yields control' do
        expect { |b| described_class.report_with_time(snitch_id, &b) }.to yield_control
      end

      it 'passes the result of the block to DMS' do
        expect(described_class).to receive(:report)
          .with(snitch_id, 'Took: 0h 0m 0s, result message').and_return('http result')
        expect(with_time).to eq('http result')
      end

      specify { expect { with_time }.not_to raise_error }

      context 'when block does not return a string' do
        let(:block) { -> { nil } }

        it 'passes the only the runtime of the block to DMS' do
          expect(described_class).to receive(:report)
            .with(snitch_id, 'Took: 0h 0m 0s').and_return('http result')
          expect(with_time).to eq('http result')
        end
      end
    end
  end

  describe DeadMansSnitch::Utils do
    describe '.seconds_to_human' do
      subject(:seconds_to_human) { described_class.seconds_to_human(seconds) }

      context 'when passed a invalid number of seconds' do
        let(:seconds) { -1000 }

        specify { expect { seconds_to_human }.to raise_error(ArgumentError) }
      end

      context 'when passed a positive number' do
        let(:seconds) { 4201 }

        it { is_expected.to eq('1h 10m 1s') }
      end
    end
  end
end
