module Gull
  class Polygon
    attr_accessor :coordinates

    def initialize(polygon)
      self.coordinates = polygon.split(' ').collect do |coords|
        coords.split(',').collect(&:to_f)
      end
    end

    def centroid
      low_lat = 0
      low_x = 0
      low_y = 0
      high_lat = 0
      high_x = 0
      high_y = 0

      coordinates.each do |pair|
        x_bounds = bounds pair.first, low_x, high_x
        low_x = x_bounds.first
        high_x = x_bounds.last

        y_bounds = bounds pair.last, low_y, high_y
        low_y = y_bounds.first
        high_y = y_bounds.last
      end

      center_x = low_x + ((high_x - low_x) / 2)
      center_y = low_y + ((high_y - low_y) / 2)

      [center_x, center_y]
    end

    def contains?(coordinate)
      # Source: http://jakescruggs.blogspot.com/2009/07/point-inside-polygon-in-ruby.html
      return false if outside_bounding_box?(coordinate)

      # Note: does NOT take into account straddling the international date line 
      # (+/- 180 degrees longitude)

      contains = false
      i = -1
      j = coordinates.size - 1
      while (i += 1) < coordinates.size
        if ((coordinates[i][0] <= coordinate[0] && coordinate[0] < coordinates[j][0]) || 
           (coordinates[j][0] <= coordinate[0] && coordinate[0] < coordinates[i][0]))
          if (coordinate[1] < (coordinates[j][1] - coordinates[i][1]) * (coordinate[0] - coordinates[i][0]) / 
                        (coordinates[j][0] - coordinates[i][0]) + coordinates[i][1])
            contains = !contains
          end
        end
        j = i
      end
      return contains
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

    private

    def bounds(point, low, high)
      if point < low || low == 0
        low = point
      elsif point > high || high == 0
        high = point
      end

      [low, high]
    end

    def coordinates_piped
      coordinates.collect { |pair| pair.join ',' }.join '|'
    end

    def outside_bounding_box?(coordinate)
      min_lat, max_lat = coordinates.map { |c| c[0] }.minmax
      min_lon, max_lon = coordinates.map { |c| c[1] }.minmax
      coordinate[0] < min_lat || coordinate[0] > max_lat || coordinate[1] < min_lon || coordinate[1] > max_lon
    end
  end
end
