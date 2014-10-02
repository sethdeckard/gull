module Gull
  class Polygon
    attr_accessor :coordinates

    def centroid
      low_x, low_y, high_x, high_y = 0, 0, 0, 0

      coordinates.each do |pair|
        latitude = pair.first
        if latitude < low_x or low_x == 0
          low_x = latitude
        elsif latitude > high_x or high_x == 0
          high_x = latitude
        end

        longitude = pair.last
        if longitude < low_y or low_y == 0
          low_y = longitude
        elsif longitude > high_y or high_y == 0
          high_y = longitude
        end
      end

      center_x = low_x + ((high_x - low_x) / 2)
      center_y = low_y + ((high_y - low_y) / 2)

      [center_x, center_y]
    end

  end
end