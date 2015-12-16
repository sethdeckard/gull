require 'httpclient'
require 'nokogiri'

module Gull
  # Gull represents an NWS/NOAA alert and provides the ability to fetch
  # them from the public web service
  class Alert
    attr_accessor :id, :title, :summary, :link, :alert_type, :polygon, :area,
                  :effective_at, :expires_at, :updated_at, :published_at,
                  :urgency, :severity, :certainty, :geocode, :vtec

    def initialize
      self.geocode = Geocode.new
    end

    def self.fetch(options = {})
      client = Client.new options
      client.fetch
    end

    def parse(element)
      parse_core_attributes element
      parse_times element
      parse_categories element

      parse_polygon element.xpath('cap:polygon').inner_text
      parse_geocode element.xpath('cap:geocode')
      parse_vtec element.xpath('cap:parameter')
    end

    private

    def parse_core_attributes(element)
      self.id = element.css('id').inner_text
      self.title = element.css('title').inner_text
      self.summary = element.css('summary').inner_text
      self.link = parse_link element
      self.alert_type = element.xpath('cap:event').inner_text
      self.area = element.xpath('cap:areaDesc').inner_text
    end

    def parse_link(element)
      link = element.css('link').first
      link.attributes['href'].value unless link.nil?
    end

    def parse_times(element)
      self.updated_at = Time.parse(element.css('updated').inner_text)
      self.published_at = Time.parse(element.css('published').inner_text)
      self.effective_at = Time.parse(element.xpath('cap:effective').inner_text)
      self.expires_at = Time.parse(element.xpath('cap:expires').inner_text)
    end

    def parse_categories(element)
      self.urgency = code_to_symbol element.xpath('cap:urgency').inner_text
      self.severity = code_to_symbol element.xpath('cap:severity').inner_text
      self.certainty = code_to_symbol element.xpath('cap:certainty').inner_text
    end

    def parse_polygon(text)
      return if text.empty?
      self.polygon = Polygon.new text
    end

    def parse_geocode(element)
      return if element.children.css('value').first.nil?

      geocode.fips6 = element.children.css('value').first.inner_text
      geocode.ugc = element.children.css('value').last.inner_text
    end

    def parse_vtec(element)
      value = element.children.css('value').inner_text
      self.vtec = value.empty? ? nil : value
    end

    def code_to_symbol(code)
      code.tr(' ', '_').downcase.to_sym
    end
  end
end
