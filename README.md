[![Gem Version](https://badge.fury.io/rb/gull.svg)](http://badge.fury.io/rb/gull)
[![CI](https://github.com/sethdeckard/gull/actions/workflows/ci.yml/badge.svg)](https://github.com/sethdeckard/gull/actions/workflows/ci.yml)
# Gull

Ruby client for parsing NOAA/NWS alerts, warnings, and watches. The name comes from the type of bird featured on the NOAA logo. Zero runtime dependencies -- uses only Ruby stdlib (`net/http`, `json`).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gull'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gull

## Usage

```ruby
require 'gull'

alerts = Gull::Alert.fetch
alert = alerts.first

alert.id
alert.alert_type
alert.title
alert.summary
alert.effective_at
alert.expires_at
alert.published_at
alert.area
alert.polygon           # Gull::Polygon or nil
alert.geocode.fips6
alert.geocode.ugc
alert.urgency
alert.severity
alert.certainty
alert.vtec
```

To get alerts for a single state or territory, pass the area option:

```ruby
alerts = Gull::Alert.fetch(area: 'OK')
```

### Polygons

Alerts with geographic boundaries include a `Polygon` object:

```ruby
alert.polygon.coordinates
# => [[34.57, -97.56], [34.77, -97.38], ...]

alert.polygon.to_s
# => "34.57,-97.56 34.77,-97.38 ..."

alert.polygon.to_wkt
# => "POLYGON((-97.56 34.57, -97.38 34.77, ...))"
```

### Error Handling

```ruby
begin
  alerts = Gull::Alert.fetch
rescue Gull::TimeoutError => e
  # request timed out
rescue Gull::HttpError => e
  # non-success response or connection failure
  e.original # wrapped exception, if any
end
```

### Advanced: Client

For direct access to unparseable features, use `Client`:

```ruby
client = Gull::Client.new(area: 'OK')
alerts = client.fetch
client.errors # features that could not be parsed
```

## Notes, Caveats

This library fetches active alerts from the [NWS API](https://api.weather.gov) (`api.weather.gov/alerts/active`), which returns GeoJSON. No authentication is required but the API does require a `User-Agent` header (set automatically by the gem). See the [NWS API docs](https://www.weather.gov/documentation/services-web-api) for more details.

The NWS will often cancel or update alerts before their expiration time. The API only returns currently active alerts.

### Urgency

| Symbol        | Definition
| :------------- |:-------------
| :immediate  | Responsive action should be taken immediately
| :expected  | Responsive action should be taken soon (within next hour)
| :future  | Responsive action should be taken in the near future
| :past  | Responsive action is no longer required
| :unknown  | Urgency not known

### Severity

| Symbol        | Definition
| :------------- |:-------------
| :extreme  | Extraordinary threat to life or property
| :severe  | Significant threat to life or property
| :moderate  | Possible threat to life or property
| :minor  | Minimal threat to life or property
| :unknown  | Severity unknown

### Certainty

| Symbol        | Definition
| :------------- |:-------------
| :very_likely  | Highly likely (p > ~ 85%) or certain
| :likely  | Likely (p > ~50%)
| :possible  | Possible but not likely (p <= ~50%)
| :unlikely  | Not expected to occur (p ~ 0)
| :unknown  | Certainty unknown


## Contributing

1. Fork it ( https://github.com/sethdeckard/gull/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the specs, make sure they pass and that new features are covered. Code coverage should be 100%.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## License

Gull is released under the [MIT License](http://www.opensource.org/licenses/MIT).
