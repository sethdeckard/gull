require 'spec_helper'

describe Gull::Client do
  it 'should initialize with options' do
    json = File.read 'spec/fixtures/alerts.json'
    stub_request(:get, 'https://test.url/alerts')
      .to_return(status: 200, body: json, headers: {})

    options = { url: 'https://test.url/alerts' }
    client = Gull::Client.new(options)
    alerts = client.fetch
    expect(alerts.size).to eq 3
  end

  it 'should fetch alerts without options' do
    json = File.read 'spec/fixtures/alerts.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_return(status: 200, body: json, headers: {})

    client = Gull::Client.new
    alerts = client.fetch
    expect(alerts.size).to eq 3
    expect(client.errors.size).to eq 0
  end

  it 'should handle features with missing event' do
    json = File.read 'spec/fixtures/missing_event.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_return(status: 200, body: json, headers: {})

    client = Gull::Client.new
    alerts = client.fetch
    expect(alerts.size).to eq 0
    expect(client.errors.size).to eq 1
  end

  it 'should raise own error if timeout occurs' do
    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_timeout

    message = 'Timeout while connecting to NWS web service'
    client = Gull::Client.new
    expect { client.fetch }.to raise_error(Gull::TimeoutError, message)
  end

  it 'should raise own error if connection errors occur' do
    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_raise(SocketError)

    message = 'Could not connect to NWS web service'
    client = Gull::Client.new
    expect { client.fetch }.to raise_error(Gull::HttpError, message) do |error|
      expect(error.original).to be_a(SocketError)
    end

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_raise(Errno::ECONNREFUSED)

    client = Gull::Client.new
    expect { client.fetch }.to raise_error(Gull::HttpError, message) do |error|
      expect(error.original).to be_a(Errno::ECONNREFUSED)
    end

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_raise(Errno::ECONNRESET)

    client = Gull::Client.new
    expect { client.fetch }.to raise_error(Gull::HttpError, message) do |error|
      expect(error.original).to be_a(Errno::ECONNRESET)
    end
  end

  it 'should filter by area' do
    json = File.read 'spec/fixtures/alerts.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active?area=OK')
      .to_return(status: 200, body: json, headers: {})

    client = Gull::Client.new(area: 'OK')
    alerts = client.fetch
    expect(alerts.size).to eq 3
  end
end
