require 'spec_helper'

describe Gull::Client do
  it 'should initialize with options' do
    xml = File.read 'spec/fixtures/alerts.xml'
    stub_request(:get, 'http://test.url')
      .with(headers: { 'Accept' => '*/*' })
      .to_return(status: 200, body: xml, headers: {})

    options = { url: 'http://test.url', strict: true }
    client = Gull::Client.new(options)
    alerts = client.fetch
    expect(alerts.size).to eq 3

    xml = File.read 'spec/fixtures/bad.xml'
    stub_request(:get, 'http://test.url')
      .with(headers: { 'Accept' => '*/*' })
      .to_return(status: 200, body: xml, headers: {})

    expect { client.fetch }
      .to raise_error(Nokogiri::XML::SyntaxError)
  end

  it 'should fetch alerts without options' do
    xml = File.read 'spec/fixtures/alerts.xml'

    stub_request(:get, 'http://alerts.weather.gov/cap/us.php?x=1')
      .with(headers: { 'Accept' => '*/*' })
      .to_return(status: 200, body: xml, headers: {})

    client = Gull::Client.new
    alerts = client.fetch
    expect(alerts.size).to eq 3
    expect(client.errors.size).to eq 0
  end

  it 'should handle incomplete entries in xml' do
    xml = File.read 'spec/fixtures/missing_cap.xml'

    stub_request(:get, 'http://alerts.weather.gov/cap/us.php?x=1')
      .with(headers: { 'Accept' => '*/*' })
      .to_return(status: 200, body: xml, headers: {})

    client = Gull::Client.new
    alerts = client.fetch
    expect(alerts.size).to eq 0
    expect(client.errors.size).to eq 1
  end
end
