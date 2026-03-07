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
alert.polygon
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

You can also generate a map (a really long URL pointing to a map) of the polygon if alert has one (requires Google Static Maps API Key)

```ruby
alert.polygon.image_url 'YOUR_GOOGLE_API_KEY'

=> "https://maps.googleapis.com/maps/api/staticmap?size=640x640&maptype=roadmap&path=color:0xff0000|weight:3|fillcolor:0xff000060|38.73,-94.22|38.75,-94.16|38.57,-93.94|38.4,-93.84|38.4,-93.91|38.73,-94.22&key=YOUR_GOOGLE_API_KEY"
```

Options can be passed for map to override defaults

```ruby
options = { width: 600, height: 300, color: '0xfbf000', weight: 4,
            fillcolor: '0xfbf00070', maptype: 'hybrid' }
alert.polygon.image_url 'YOUR_GOOGLE_API_KEY', options
```

##Notes, Caveats
This library fetches active alerts from the [NWS API](https://api.weather.gov) (`api.weather.gov/alerts/active`), which returns GeoJSON. No authentication is required but the API does require a `User-Agent` header (set automatically by the gem).

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
