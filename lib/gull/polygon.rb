# frozen_string_literal: true

module Gull
  class Polygon
    attr_accessor :coordinates

    def initialize(coords)
      self.coordinates = coords.map { |point| [point[1], point[0]] }
    end

    def to_s
      coordinates.map { |pair| pair.join(',') }.join(' ')
    end

    def to_wkt
      pairs = coordinates.map { |pair| "#{pair.last} #{pair.first}" }
                         .join(', ')
      "POLYGON((#{pairs}))"
    end
  end
end
