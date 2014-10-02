module Gull
  class Polygon
    attr_accessor :coordinates

    def initialize polygon
      self.coordinates = polygon.split(" ").collect {|coords| coords.split(",").collect {|coord| coord.to_f} }
    end

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

    def image_url api_key, options={}
      opts = { 
        :width => 640, 
        :height => 640, 
        :color => "0xff0000", 
        :weight => 3, 
        :fillcolor => "0xff000060" 
      }.merge(options)

      url_base = "http://maps.googleapis.com/maps/api/staticmap"
      "#{url_base}?size=#{opts[:width]}x#{opts[:height]}&maptype=roadmap&path=color:#{opts[:color]}" +
      "|weight:#{opts[:weight]}|fillcolor:#{opts[:fillcolor]}|#{coordinates_piped}&key=#{api_key}"
    end

    private 

    def coordinates_piped
      coordinates.collect {|pair| pair.join "," }.join "|"
    end

  end
end