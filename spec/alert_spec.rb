# frozen_string_literal: true

require 'spec_helper'

describe Gull::Alert do
  it 'should initialize with geocode' do
    alert = Gull::Alert.new
    expect(alert.geocode).not_to be_nil
  end

  it 'should fetch parsed alerts' do
    json = File.read 'spec/fixtures/alerts.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_return(status: 200, body: json, headers: {})

    alerts = Gull::Alert.fetch
    expect(alerts.size).to eq(3)

    first = alerts.first
    expect(first.id).to eq 'urn:oid:2.49.0.1.840.0.1111'
    expect(first.link).to eq 'https://api.weather.gov/alerts/urn:oid:2.49.0.1.840.0.1111'
    expect(first.alert_type).to eq 'Heat Advisory'
    expect(first.title).to eq 'Heat Advisory issued October 01 at 8:40AM PDT ' \
                              'until October 03 at 9:00PM PDT by NWS'
    expect(first.summary).to eq 'SUMMARY TEXT'

    coordinates = [[27.35, -81.79], [27.14, -81.89], [27.04, -81.97],
                   [27.04, -82.02], [27.14, -81.97], [27.35, -81.86],
                   [27.35, -81.79]]
    expect(first.polygon.coordinates).to eq coordinates

    expect(first.effective_at).to eq Time.parse('2014-10-01T08:40:00-07:00')
    expect(first.expires_at).to eq Time.parse('2014-10-03T21:00:00-07:00')
    expect(first.updated_at).to eq Time.parse('2014-10-01T08:40:00-07:05')
    expect(first.published_at).to eq Time.parse('2014-10-01T08:40:00-07:06')

    expect(first.area).to eq 'Southern Salinas Valley, Arroyo Seco and Lake ' \
                             'San Antonio'
    expect(first.urgency).to eq :expected
    expect(first.severity).to eq :minor
    expect(first.certainty).to eq :very_likely

    expect(first.geocode.fips6).to be_nil
    expect(first.geocode.ugc).to be_nil

    expect(first.vtec).to eq '/O.NEW.KMTR.HT.Y.0002.141002T1900Z-141004T0400Z/'

    second = alerts[1]
    expect(second.polygon).to be_nil

    expect(second.geocode.fips6).to eq '006001 006013 006041 006053 006055 ' \
                                       '006069 006075 006081 006085 006087 006097'
    expect(second.geocode.ugc).to eq 'CAZ006 CAZ505 CAZ506 CAZ507 CAZ508 ' \
                                     'CAZ509 CAZ510 CAZ511 CAZ512 CAZ513 CAZ516 CAZ517 CAZ518 CAZ528 ' \
                                     'CAZ529 CAZ530'

    expect(second.vtec).to be_nil

    third = alerts[2]
    expect(third.vtec).to be_nil
  end

  it 'should fetch with area option' do
    json = File.read 'spec/fixtures/alerts.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active?area=OK')
      .to_return(status: 200, body: json, headers: {})

    alerts = Gull::Alert.fetch(area: 'OK')
    expect(alerts.size).to eq(3)
  end

  it 'should parse MultiPolygon geometry' do
    json = File.read 'spec/fixtures/multipolygon_alert.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_return(status: 200, body: json, headers: {})

    alerts = Gull::Alert.fetch
    first = alerts.first
    coordinates = [[34.57, -97.56], [34.77, -97.38],
                   [34.75, -97.17], [34.57, -97.56]]
    expect(first.polygon.coordinates).to eq coordinates
  end

  it 'should handle empty alerts' do
    json = File.read 'spec/fixtures/empty.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_return(status: 200, body: json, headers: {})

    alerts = Gull::Alert.fetch
    expect(alerts.size).to eq(0)
  end

  it 'should handle missing event' do
    json = File.read 'spec/fixtures/missing_event.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_return(status: 200, body: json, headers: {})

    alerts = Gull::Alert.fetch
    expect(alerts.size).to eq 0
  end
end
