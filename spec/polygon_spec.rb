require 'spec_helper'

describe Gull::Polygon do
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

  it 'should return original string representation' do
    text = '34.57,-97.56 34.77,-97.38 34.75,-97.17 ' \
      '34.64,-97.11 34.64,-97.14 34.62,-97.14 34.62,-97.2 34.6,-97.19 34.59,' \
      '-97.17 34.57,-97.17 34.5,-97.3 34.51,-97.56 34.57,-97.56'
    polygon = Gull::Polygon.new text
    expect(polygon.to_s).to eq text
  end

  it 'should output polygons in WKT format' do
    text = '34.57,-97.56 34.77,-97.38 34.75,-97.17 ' \
      '34.64,-97.11 34.64,-97.14 34.62,-97.14 34.62,-97.2 34.6,-97.19 34.59,' \
      '-97.17 34.57,-97.17 34.5,-97.3 34.51,-97.56 34.57,-97.56'

    wkt_text = 'POLYGON((-97.56 34.57, -97.38 34.77, -97.17 34.75,' \
      ' -97.11 34.64, -97.14 34.64, -97.14 34.62, -97.2 34.62, -97.19 34.6,' \
      ' -97.17 34.59, -97.17 34.57, -97.3 34.5, -97.56 34.51, -97.56 34.57))'

    polygon = Gull::Polygon.new text
    expect(polygon.to_wkt).to eq wkt_text
  end
end
