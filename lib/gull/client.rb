require 'httpclient'
require 'nokogiri'

module Gull
  # Client exposes methods and options for fetching alerts from the NWS/NOAA
  # web service
  class Client
    attr_accessor :errors

    def initialize(options = {})
      @options = {
        url: 'http://alerts.weather.gov/cap/us.php?x=1',
        strict: false
      }.merge options
    end

    def fetch
      self.errors = []
      content = response
      document = Nokogiri::XML content do |config|
        config.strict if @options[:strict]
      end
      process document.xpath('//xmlns:feed/xmlns:entry', namespaces)
    end

    private

    def response
      client = HTTPClient.new
      begin
        return client.get_content @options[:url]
      rescue HTTPClient::TimeoutError
        raise TimeoutError, 'Timeout while connecting to NWS web service'
      rescue HTTPClient::KeepAliveDisconnected, SocketError, Errno::ECONNREFUSED
        raise HttpError, 'Could not connect to NWS web service'
      end
    end

    def process(entries)
      alerts = []
      entries.each do |entry|
        alert = create_instance entry
        alerts.push alert unless alert.nil?
        errors.push entry if alert.nil?
      end

      alerts
    end

    def create_instance(entry)
      return if entry.xpath('cap:event').empty?

      alert = Alert.new
      alert.parse entry
      alert
    end

    def namespaces
      { 'xmlns' => 'http://www.w3.org/2005/Atom',
        'cap' => 'urn:oasis:names:tc:emergency:cap:1.1',
        'ha' => 'http://www.alerting.net/namespace/index_1.0' }
    end
  end
end
