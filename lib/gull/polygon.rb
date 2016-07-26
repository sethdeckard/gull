module Gull
  class Polygon
    attr_accessor :coordinates

    def initialize(polygon)
      self.coordinates = polygon.split(' ')
                                .map { |point| point.split(',').map(&:to_f) }
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

      url_base = 'http://maps.googleapis.com/maps/api/staticmap'
      "#{url_base}?size=#{options[:width]}x#{options[:height]}" \
      "&maptype=#{options[:maptype]}&path=color:#{options[:color]}" \
      "|weight:#{options[:weight]}|fillcolor:#{options[:fillcolor]}" \
      "|#{coordinates_piped}&key=#{api_key}"
    end

    def to_s
      coordinates.map { |pair| pair.join(',') }.join(' ')
    end

    # Returns well-known text (WKT) formatted polygon
    def to_wkt
      pairs = coordinates.map { |pair| "#{pair.last} #{pair.first}" }
                         .join(', ')
      "POLYGON((#{pairs}))"
    end

    private

    def coordinates_piped
      coordinates.map { |pair| pair.join ',' }.join '|'
    end
  end
end
