require 'spec_helper'

describe Gull::Polygon do
  it 'should return centroid of polygon' do
    polygon = Gull::Polygon.new '34.57,-97.56 34.77,-97.38 34.75,-97.17 ' \
      '34.64,-97.11 34.64,-97.14 34.62,-97.14 34.62,-97.2 34.6,-97.19 34.59,' \
      '-97.17 34.57,-97.17 34.5,-97.3 34.51,-97.56 34.57,-97.56'
    expect(polygon.centroid).to eq [34.635000000000005, -97.33500000000001]

    polygon = Gull::Polygon.new '30.71,-86.4 30.78,-86.04 30.27,-86.01 30.35,' \
      '-86.28 30.37,-86.4 30.39,-86.4 30.4,-86.4 30.4,-86.34 30.43,-86.32' \
      ' 30.4,-86.29 30.43,-86.25 30.39,-86.16 30.39,-86.13 30.47,-86.21 ' \
      '30.48,-86.26 30.46,-86.4 30.71,-86.4'
    expect(polygon.centroid).to eq [30.525, -86.20500000000001]

    polygon = Gull::Polygon.new '30.39,-86.59 30.38,-86.8 30.79,-86.72 30.78,' \
      '-86.38 30.45,-86.39 30.44,-86.42 30.48,-86.46 30.45,-86.49 30.42,' \
      '-86.59 30.4,-86.58 30.4,-86.53 30.42,-86.49 30.42,-86.44 30.41,-86.4 ' \
      '30.38,-86.39 30.37,-86.4 30.39,-86.59'
    expect(polygon.centroid).to eq [30.58, -86.59]
  end

  it 'should return static map image url' do
    polygon = Gull::Polygon.new '34.57,-97.56 34.77,-97.38 34.75,-97.17'

    api_key = 'testkey'
    options = { width: 600, height: 300, color: '0xfbf000', weight: 4,
                fillcolor: '0xfbf00070', maptype: 'hybrid' }
    url = polygon.image_url api_key, options
    expected_url = 'http://maps.googleapis.com/maps/api/staticmap?' \
      'size=600x300&maptype=hybrid&path=color:0xfbf000' \
      '|weight:4|fillcolor:0xfbf00070|34.57,-97.56|34.77,-97.38|34.75,-97.17' \
      '&key=testkey'
    expect(url).to eq expected_url

    url = polygon.image_url api_key
    expected_url = 'http://maps.googleapis.com/maps/api/staticmap?' \
      'size=640x640&maptype=roadmap&path=color:0xff0000' \
      '|weight:3|fillcolor:0xff000060|34.57,-97.56|34.77,-97.38|34.75,-97.17' \
      '&key=testkey'
    expect(url).to eq expected_url
  end
end
