require 'httpclient'
require 'nokogiri'

module Gull
  class Alert
    attr_accessor :id, :title, :summary, :alert_type, :polygon, :area, :effective_at, :expires_at,
      :urgency, :severity, :certainty, :geocode

    def initialize
      self.geocode = Geocode.new
    end

    def self.fetch
      client = HTTPClient.new
      response = client.get_content "http://alerts.weather.gov/cap/us.php?x=0"
      document = Nokogiri::XML response
      self.process document.css('feed/entry')
    end

    def parse_geocode element
      self.geocode.fips6 = element.children.css('value').first.inner_text
      self.geocode.ugc = element.children.css('value').last.inner_text
    end

    def parse_polygon text
      unless text.empty?
        self.polygon = Polygon.new text
      end
    end

    private

    def self.process entries
      alerts = []
      entries.each do |entry|
        alerts.push create_instance entry
      end

      alerts
    end

    def self.create_instance entry
      alert = Alert.new
      alert.id = entry.css('id').inner_text
      alert.alert_type = entry.xpath('cap:event').inner_text
      alert.title = entry.css('title').inner_text
      alert.summary = entry.css('summary').inner_text
      alert.area = entry.xpath('cap:areaDesc').inner_text
      alert.effective_at = Time.parse(entry.xpath('cap:effective').inner_text).utc
      alert.expires_at = Time.parse(entry.xpath('cap:expires').inner_text).utc
      alert.urgency = code_to_symbol entry.xpath('cap:urgency').inner_text
      alert.severity = code_to_symbol entry.xpath('cap:severity').inner_text
      alert.certainty = code_to_symbol entry.xpath('cap:certainty').inner_text

      alert.parse_polygon entry.xpath('cap:polygon').inner_text
      alert.parse_geocode entry.xpath('cap:geocode')

      alert  
    end

    def self.code_to_symbol code
      code.gsub(' ','_').downcase.to_sym
    end

  end
end