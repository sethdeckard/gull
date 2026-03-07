# frozen_string_literal: true

module Gull
  class Polygon
    attr_accessor :coordinates

    def initialize(coords)
      self.coordinates = coords.map { |point| [point[1], point[0]] }
    end

    def image_url(api_key, options = {})
      options = {
        width: 640,
        height: 640,
        color: '0xff0000',
        weight: 3,
        fillcolor: '0xff000060',
        maptype: 'roadmap'
      }.merge(options)

      url_base = 'https://maps.googleapis.com/maps/api/staticmap'
      "#{url_base}?size=#{options[:width]}x#{options[:height]}" \
        "&maptype=#{options[:maptype]}&path=color:#{options[:color]}" \
        "|weight:#{options[:weight]}|fillcolor:#{options[:fillcolor]}" \
        "|#{coordinates_piped}&key=#{api_key}"
    end

    def to_s
      coordinates.map { |pair| pair.join(',') }.join(' ')
    end

    def to_wkt
      pairs = coordinates.map { |pair| "#{pair.last} #{pair.first}" }
                         .join(', ')
      "POLYGON((#{pairs}))"
    end

    private

    def coordinates_piped
      coordinates.map { |pair| pair.join(',') }.join('|')
    end
  end
end
