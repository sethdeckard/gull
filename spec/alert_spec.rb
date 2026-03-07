# frozen_string_literal: true

require 'spec_helper'

describe Gull::Alert do
  def load_feature(name)
    JSON.parse(File.read("spec/fixtures/features/#{name}"))
  end

  def wrap_features(*features)
    { 'type' => 'FeatureCollection', 'features' => features }.to_json
  end

  def stub_alerts(json)
    stub_request(:get, 'https://api.weather.gov/alerts/active')
      .to_return(status: 200, body: json, headers: {})
  end

  it 'should initialize with geocode' do
    alert = Gull::Alert.new
    expect(alert.geocode).not_to be_nil
  end

  it 'should fetch and parse all alerts' do
    json = File.read 'spec/fixtures/alerts.json'
    stub_alerts(json)

    alerts = Gull::Alert.fetch
    expect(alerts.size).to eq(44)
  end

  it 'should parse alert with polygon and no VTEC' do
    feature = load_feature('polygon_no_vtec.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    expect(alert.id).to eq feature['properties']['id']
    expect(alert.link).to eq feature['properties']['@id']
    expect(alert.alert_type).to eq 'Special Weather Statement'
    expect(alert.title).to start_with 'Special Weather Statement'
    expect(alert.summary).to start_with 'At 748 AM CST'
    expect(alert.area).to eq 'Sevier; Howard; Hempstead'

    expect(alert.effective_at).to eq Time.parse('2026-03-07T07:48:00-06:00')
    expect(alert.expires_at).to eq Time.parse('2026-03-07T08:15:00-06:00')
    expect(alert.published_at).to eq Time.parse('2026-03-07T07:48:00-06:00')
    expect(alert.updated_at).to eq Time.parse('2026-03-07T07:48:00-06:00')

    expect(alert.urgency).to eq :expected
    expect(alert.severity).to eq :moderate
    expect(alert.certainty).to eq :observed

    expect(alert.polygon).not_to be_nil
    expect(alert.polygon.coordinates.first).to eq [34.21, -93.93]
    expect(alert.polygon.coordinates.size).to eq 18

    expect(alert.geocode.fips6).to eq '005133 005061 005057'
    expect(alert.geocode.ugc).to eq 'ARZ050 ARZ051 ARZ060'

    expect(alert.vtec).to be_nil
  end

  it 'should parse alert with polygon and VTEC' do
    feature = load_feature('polygon_with_vtec.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    expect(alert.alert_type).to eq 'Severe Thunderstorm Warning'
    expect(alert.urgency).to eq :immediate
    expect(alert.severity).to eq :severe
    expect(alert.certainty).to eq :observed
    expect(alert.polygon).not_to be_nil
    expect(alert.polygon.coordinates.size).to eq 5
    expect(alert.vtec).to eq '/O.NEW.KLZK.SV.W.0013.260307T1328Z-260307T1415Z/'
  end

  it 'should parse alert with null geometry' do
    feature = load_feature('null_geometry.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    expect(alert.alert_type).to eq 'Tornado Watch'
    expect(alert.urgency).to eq :future
    expect(alert.severity).to eq :extreme
    expect(alert.certainty).to eq :possible
    expect(alert.polygon).to be_nil
    expect(alert.geocode.ugc).not_to be_nil
    expect(alert.geocode.fips6).not_to be_nil
    expect(alert.vtec).to eq '/O.CON.KLZK.TO.A.0022.000000T0000Z-260307T1400Z/'
  end

  it 'should parse flood advisory with minor severity' do
    feature = load_feature('flood_advisory.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    expect(alert.alert_type).to eq 'Flood Advisory'
    expect(alert.severity).to eq :minor
    expect(alert.polygon).not_to be_nil
    expect(alert.vtec).not_to be_nil
  end

  it 'should parse blizzard warning with extreme severity' do
    feature = load_feature('blizzard_warning.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    expect(alert.alert_type).to eq 'Blizzard Warning'
    expect(alert.severity).to eq :extreme
    expect(alert.polygon).to be_nil
  end

  it 'should parse MultiPolygon geometry' do
    feature = load_feature('multipolygon.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    coordinates = [[34.57, -97.56], [34.77, -97.38],
                   [34.75, -97.17], [34.57, -97.56]]
    expect(alert.polygon.coordinates).to eq coordinates
  end

  it 'should handle empty geocode' do
    feature = load_feature('empty_geocode.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    expect(alert.geocode.fips6).to be_nil
    expect(alert.geocode.ugc).to be_nil
  end

  it 'should fetch with area option' do
    json = File.read 'spec/fixtures/alerts.json'

    stub_request(:get, 'https://api.weather.gov/alerts/active?area=OK')
      .to_return(status: 200, body: json, headers: {})

    alerts = Gull::Alert.fetch(area: 'OK')
    expect(alerts.size).to eq(44)
  end

  it 'should handle empty alerts' do
    json = File.read 'spec/fixtures/empty.json'
    stub_alerts(json)

    alerts = Gull::Alert.fetch
    expect(alerts.size).to eq(0)
  end

  it 'should handle missing onset time' do
    feature = load_feature('missing_times.json')
    stub_alerts(wrap_features(feature))

    alert = Gull::Alert.fetch.first

    expect(alert.effective_at).to be_nil
    expect(alert.expires_at).to eq Time.parse('2026-03-07T08:15:00-06:00')
    expect(alert.updated_at).to eq Time.parse('2026-03-07T07:48:00-06:00')
    expect(alert.published_at).to eq Time.parse('2026-03-07T07:48:00-06:00')
  end

  it 'should handle missing event' do
    json = File.read 'spec/fixtures/missing_event.json'
    stub_alerts(json)

    alerts = Gull::Alert.fetch
    expect(alerts.size).to eq 0
  end
end
