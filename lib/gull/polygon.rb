# frozen_string_literal: true

module Gull
  # Represents the geographic boundary of an alert as a series of
  # lat/lon coordinate pairs. Coordinates are stored in [lat, lon]
  # order.
  class Polygon
    attr_accessor :coordinates

    # Accepts GeoJSON coordinates ([lon, lat]) and stores them as
    # [lat, lon].
    def initialize(coords)
      self.coordinates = coords.map { |point| [point[1], point[0]] }
    end

    # Returns coordinates as "lat,lon lat,lon ..." string.
    def to_s
      coordinates.map { |pair| pair.join(',') }.join(' ')
    end

    # Returns coordinates in Well-Known Text format.
    def to_wkt
      pairs = coordinates.map { |pair| "#{pair.last} #{pair.first}" }
                         .join(', ')
      "POLYGON((#{pairs}))"
    end
  end
end
