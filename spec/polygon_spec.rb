require 'spec_helper'

describe Gull::Polygon do
  it "should return centroid of polygon" do
    polygon = Gull::Polygon.new
    polygon.coordinates = [[34.57,-97.56], [34.77,-97.38], [34.75,-97.17], [34.64,-97.11], [34.64,-97.14], 
      [34.62,-97.14], [34.62,-97.2], [34.6,-97.19], [34.59,-97.17], [34.57,-97.17], [34.5,-97.3], 
      [34.51,-97.56], [34.57,-97.56]]

    expect(polygon.centroid).to eq [34.635000000000005, -97.33500000000001]
  end
end