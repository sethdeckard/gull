# frozen_string_literal: true

module Gull
  class Client
    URL = 'https://api.weather.gov/alerts/active'
    USER_AGENT = "gull/#{VERSION} (Ruby #{RUBY_VERSION})".freeze

    attr_accessor :errors

    def initialize(options = {})
      @options = options
    end

    def fetch
      self.errors = []
      json = response
      data = JSON.parse(json)
      process(data['features'] || [])
    end

    private

    def response
      uri = build_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = USER_AGENT
      request['Accept'] = 'application/geo+json'
      result = http.request(request)
      unless result.is_a?(Net::HTTPSuccess)
        raise HttpError, "NWS API returned #{result.code}"
      end

      result.body
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise TimeoutError,
            'Timeout while connecting to NWS web service'
    rescue SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET
      raise HttpError,
            'Could not connect to NWS web service'
    end

    def build_uri
      uri = URI(URL)
      if @options[:area]
        params = URI.decode_www_form(uri.query || '')
        params << ['area', @options[:area]]
        uri.query = URI.encode_www_form(params)
      end
      uri
    end

    def process(features)
      alerts = []
      features.each do |feature|
        alert = create_instance(feature)
        alerts.push(alert) unless alert.nil?
        errors.push(feature) if alert.nil?
      end
      alerts
    end

    def create_instance(feature)
      properties = feature['properties']
      return if properties.nil? || properties['event'].nil?

      alert = Alert.new
      alert.parse(feature)
      alert
    end
  end
end
