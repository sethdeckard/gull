require 'spec_helper'

describe Gull::Alert do
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
    
    polygon = [[27.35,-81.79], [27.14,-81.89], [27.04,-81.97], [27.04,-82.02], [27.14,-81.97], [27.35,-81.86],
      [27.35,-81.79]]
    expect(first.polygon).to eq polygon
    
    expect(first.effective_at).to eq Time.parse("2014-10-01T08:40:00-07:00")
    expect(first.expires_at).to eq Time.parse("2014-10-03T21:00:00-07:00")
    expect(first.area).to eq "Southern Salinas Valley, Arroyo Seco and Lake San Antonio"
    expect(first.urgency).to eq :expected
    expect(first.severity).to eq :minor
    expect(first.certainty).to eq :very_likely
  end
end