require 'httpclient'
require 'nokogiri'

module Gull
  class Alert
    attr_accessor :id, :title, :summary, :alert_type, :polygon, :area, :effective_at, :expires_at,
      :urgency, :severity, :certainty

    def initialize(attributes = {})
    end

    def self.fetch
      client = HTTPClient.new
      response = client.get_content "http://alerts.weather.gov/cap/us.php?x=0"
      doc = Nokogiri::XML response
      entries = doc.xpath('//cap:event').collect {|e| e.parent }
      self.process entries
    end

    def self.process entries
      alerts = []
      entries.each do |entry|
        alert = Alert.new
        alert.id = entry.css('id').inner_text
        alert.alert_type = entry.xpath('cap:event').inner_text
        alert.title = entry.css('title').inner_text
        alert.summary = entry.css('summary').inner_text
        alert.polygon = entry.xpath('cap:polygon').inner_text
        alert.area = entry.xpath('cap:areaDesc').inner_text
        alert.effective_at = Time.parse(entry.xpath('cap:effective').inner_text).utc
        alert.expires_at = Time.parse(entry.xpath('cap:expires').inner_text).utc
        alert.urgency = entry.xpath('cap:urgency').inner_text
        alert.severity = entry.xpath('cap:severity').inner_text
        alert.certainty = entry.xpath('cap:certainty').inner_text
        alerts.push alert
      end

      alerts
    end
    
  end
end