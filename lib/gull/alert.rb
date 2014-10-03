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

    def parse element
      self.id = element.css('id').inner_text
      self.title = element.css('title').inner_text
      self.summary = element.css('summary').inner_text

      parse_cap element

      parse_polygon element.xpath('cap:polygon').inner_text
      parse_geocode element.xpath('cap:geocode')
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
      alert.parse entry
      alert  
    end

    def parse_cap element
      self.alert_type = element.xpath('cap:event').inner_text
      self.area = element.xpath('cap:areaDesc').inner_text
      self.effective_at = Time.parse(element.xpath('cap:effective').inner_text).utc
      self.expires_at = Time.parse(element.xpath('cap:expires').inner_text).utc
      self.urgency = code_to_symbol element.xpath('cap:urgency').inner_text
      self.severity = code_to_symbol element.xpath('cap:severity').inner_text
      self.certainty = code_to_symbol element.xpath('cap:certainty').inner_text
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

    def code_to_symbol code
      code.gsub(' ','_').downcase.to_sym
    end

  end
end