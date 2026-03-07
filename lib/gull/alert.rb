# frozen_string_literal: true

module Gull
  class Alert
    attr_accessor :id, :title, :summary, :link, :alert_type, :polygon,
                  :area, :effective_at, :expires_at, :updated_at,
                  :published_at, :urgency, :severity, :certainty,
                  :geocode, :vtec

    def initialize
      self.geocode = Geocode.new
    end

    def self.fetch(options = {})
      client = Client.new(options)
      client.fetch
    end

    def parse(feature)
      props = feature['properties']
      parse_core_attributes(feature, props)
      parse_times(props)
      parse_categories(props)
      parse_polygon(feature)
      parse_geocode(props)
      parse_vtec(props)
    end

    private

    def parse_core_attributes(feature, props)
      self.id = props['id']
      self.title = props['headline']
      self.summary = props['description']
      self.link = props['@id'] || feature['id']
      self.alert_type = props['event']
      self.area = props['areaDesc']
    end

    def parse_times(props)
      self.effective_at = Time.parse(props['effective'])
      self.expires_at = Time.parse(props['expires'])
      self.published_at = Time.parse(props['sent'])
      self.updated_at = Time.parse(props['onset'] || props['sent'])
    end

    def parse_categories(props)
      self.urgency = code_to_symbol(props['urgency'])
      self.severity = code_to_symbol(props['severity'])
      self.certainty = code_to_symbol(props['certainty'])
    end

    def parse_polygon(feature)
      geometry = feature['geometry']
      return if geometry.nil?

      coords = geometry['coordinates']
      return if coords.nil? || coords.empty?

      self.polygon = Polygon.new(coords.first)
    end

    def parse_geocode(props)
      geocode_data = props['geocode']
      return if geocode_data.nil?

      ugc = geocode_data['UGC']
      geocode.ugc = ugc&.join(' ')

      fips = geocode_data['SAME']
      geocode.fips6 = fips&.join(' ')
    end

    def parse_vtec(props)
      params = props['parameters']
      return if params.nil?

      vtec_values = params['VTEC']
      self.vtec = vtec_values&.first
    end

    def code_to_symbol(code)
      return :unknown if code.nil?

      code.tr(' ', '_').downcase.to_sym
    end
  end
end
