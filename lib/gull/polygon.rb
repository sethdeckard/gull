module Gull
  class Polygon
    attr_accessor :coordinates

    def initialize polygon
      self.coordinates = polygon.split(" ").collect {|coords| coords.split(",").collect {|coord| coord.to_f} }
    end

    def centroid
      low_x = 0 
      low_y = 0
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

    def image_url api_key, options={}
      opts = { 
        :width => 640, 
        :height => 640, 
        :color => "0xff0000", 
        :weight => 3, 
        :fillcolor => "0xff000060",
        :maptype => "roadmap"
      }.merge(options)

      url_base = "http://maps.googleapis.com/maps/api/staticmap"
      "#{url_base}?size=#{opts[:width]}x#{opts[:height]}&maptype=#{opts[:maptype]}&path=color:#{opts[:color]}" +
      "|weight:#{opts[:weight]}|fillcolor:#{opts[:fillcolor]}|#{coordinates_piped}&key=#{api_key}"
    end

    private 

    def bounds point, low, high
      if point < low or low == 0
        low = point
      elsif point > high or high == 0
        high = point
      end

      [low, high]
    end

    def coordinates_piped
      coordinates.collect {|pair| pair.join "," }.join "|"
    end

  end
end