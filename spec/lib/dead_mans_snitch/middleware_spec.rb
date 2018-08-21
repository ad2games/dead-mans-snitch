# frozen_string_literal: true

require 'spec_helper'
require 'dead_mans_snitch/middleware'

# rubocop:disable RSpec/NamedSubject
describe DeadMansSnitch::Middleware do
  let(:worker_class) do
    cls = Class.new
    cls.include(Sidekiq::Worker)
    cls
  end

  it 'yields control without calling dms' do
    expect { |b| subject.call(worker_class.new, {}, 'default', &b) }.to yield_control
    expect(DeadMansSnitch).not_to receive(:report_with_time)
  end

  context 'when we set a dms_id in the sidekiq_options' do
    let(:dms_id) { 'asdklj203blkasd' }
    let(:worker_class) do
      cls = super()
      cls.sidekiq_options(dms_id: dms_id)
      cls
    end

    it 'calls dms and yields control' do
      expect(DeadMansSnitch).to receive(:report_with_time).with(dms_id).and_call_original
      expect { |b| subject.call(worker_class.new, {}, 'default', &b) }.to yield_control
    end
  end
end
# rubocop:enable RSpec/NamedSubject
