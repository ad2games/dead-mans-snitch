# frozen_string_literal: true

require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'

class DeadMansSnitch
  def self.report(snitch_id, message = nil)
    return false if snitch_id.nil? || snitch_id == ''
    uri                  = URI.parse("https://nosnch.in/#{snitch_id}")
    http                 = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl         = true
    http.verify_mode     = OpenSSL::SSL::VERIFY_NONE
    request              = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data('m' => message)
    http.request(request)
  rescue Exception # rubocop:disable Lint/RescueException
    false
  end

  def self.report_with_time(snitch_id)
    start = Time.now
    result = yield
    finish = Time.now

    message = "Took: #{Utils.seconds_to_human(finish - start)}"
    message = "#{message}, #{result}"[0, 255] if result.is_a? String

    report snitch_id, message
  end

  module Utils
    def self.seconds_to_human(seconds)
      raise ArgumentError if seconds.nil? || seconds.negative?

      seconds = seconds.to_i
      hours = seconds / 3600
      seconds = seconds % 3600
      minutes = seconds / 60
      seconds = seconds % 60

      "#{hours}h #{minutes}m #{seconds}s"
    end
  end
end
