# frozen_string_literal: true

module Gull
  # Represents a single NWS weather alert (warning, watch, or
  # advisory). Use +Alert.fetch+ to retrieve active alerts from the
  # NWS API.
  class Alert
    # @!attribute id [rw] NWS alert identifier
    # @!attribute title [rw] Alert headline
    # @!attribute summary [rw] Full alert description text
    # @!attribute link [rw] Canonical URL for this alert
    # @!attribute alert_type [rw] Event type (e.g. "Tornado Warning")
    # @!attribute polygon [rw] Alert area as a Polygon, or nil
    # @!attribute area [rw] Human-readable area description
    # @!attribute effective_at [rw] Time the alert takes effect
    # @!attribute expires_at [rw] Time the alert expires
    # @!attribute updated_at [rw] Onset time, or sent time if absent
    # @!attribute published_at [rw] Time the alert was sent
    # @!attribute urgency [rw] Urgency level as a Symbol
    # @!attribute severity [rw] Severity level as a Symbol
    # @!attribute certainty [rw] Certainty level as a Symbol
    # @!attribute geocode [rw] Geocode with UGC and FIPS codes
    # @!attribute vtec [rw] VTEC string, or nil
    attr_accessor :id, :title, :summary, :link, :alert_type, :polygon,
                  :area, :effective_at, :expires_at, :updated_at,
                  :published_at, :urgency, :severity, :certainty,
                  :geocode, :vtec

    def initialize
      self.geocode = Geocode.new
    end

    # Fetches active alerts from the NWS API.
    def self.fetch(options = {})
      client = Client.new(options)
      client.fetch
    end

    # Populates this alert from a GeoJSON feature hash.
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

      ring = coords.first
      ring = ring.first if geometry['type'] == 'MultiPolygon'
      self.polygon = Polygon.new(ring)
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
