require 'spec_helper'

describe Gull::Alert do
  it "should initialize with geocode" do
    alert = Gull::Alert.new
    expect(alert.geocode).not_to be_nil
  end

  it "should fetch parsed alerts" do
    xml = File.read "spec/alerts.xml"

    stub_request(:get, "http://alerts.weather.gov/cap/us.php?x=0").
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:status => 200, :body => xml, :headers => {})

    alerts = Gull::Alert.fetch
    expect(alerts.size).to eq(3)

    first = alerts.first
    expect(first.id).to eq "http://alerts.weather.gov/cap/wwacapget.php?x=CA125171381DD0.HeatAdvisory"
    expect(first.alert_type).to eq "Heat Advisory"
    expect(first.title).to eq "Heat Advisory issued October 01 at 8:40AM PDT until October 03 at 9:00PM PDT by NWS"
    expect(first.summary).to eq "SUMMARY TEXT"
    
    coordinates = [[27.35,-81.79], [27.14,-81.89], [27.04,-81.97], [27.04,-82.02], [27.14,-81.97], [27.35,-81.86],
      [27.35,-81.79]]
    expect(first.polygon.coordinates).to eq coordinates
    
    expect(first.effective_at).to eq Time.parse("2014-10-01T08:40:00-07:00")
    expect(first.expires_at).to eq Time.parse("2014-10-03T21:00:00-07:00")
    expect(first.area).to eq "Southern Salinas Valley, Arroyo Seco and Lake San Antonio"
    expect(first.urgency).to eq :expected
    expect(first.severity).to eq :minor
    expect(first.certainty).to eq :very_likely

    expect(first.geocode.fips6).to eq "006001 006013 006041 006053 006055 006069 006075 006081 006085 006087 006097"
    expect(first.geocode.ugc).to eq "CAZ006 CAZ505 CAZ506 CAZ507 CAZ508 CAZ509 CAZ510 CAZ511 CAZ512"

    second = alerts[1]
    expect(second.polygon).to be_nil
  end
end