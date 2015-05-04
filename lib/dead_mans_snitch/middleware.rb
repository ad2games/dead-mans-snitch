require 'dead_mans_snitch'
require 'sidekiq'

class DeadMansSnitch
  class Middleware
    def call(worker, msg, queue, &block)
      if worker.sidekiq_options_hash && dms_id = worker.sidekiq_options_hash['dms_id']
        DeadMansSnitch.report_with_time(dms_id, &block)
      else
        yield
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add DeadMansSnitch::Middleware
  end
end
