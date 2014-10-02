[![Build Status](https://travis-ci.org/sethdeckard/gull.svg?branch=master)](https://travis-ci.org/sethdeckard/gull)
# Gull

Ruby client for parsing NOAA/NWS alerts, warnings, and watches. The name comes from the type of bird featured on the NOAA logo.

## Installation

Add this line to your application's Gemfile:

    gem 'gull'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gull

## Usage

	require 'gull/alert'

	alerts = Gull::Alert.fetch
	alert = alert.first
	
	#Generate map of polygon (if alert has one)
	#requires Google Static Maps API Key
	url = alert.polygon.image_url "your_api_key"
	
	puts url
	=> "http://maps.googleapis.com/maps/api/staticmap?size=640x640&maptype=roadmap&path=color:0xff0000|weight:3|fillcolor:0xff000060|38.73,-94.22|38.75,-94.16|38.57,-93.94|38.4,-93.84|38.4,-93.91|38.73,-94.22&key=your_api_key"
	
	#options can be passed for map to override defaults
	options = { :width => 600, :height => 300, :color => "0xfbf000", :weight => 4, :fillcolor => "0xfbf00070", :maptype => "hybrid" } 
	
	alert.polygon.image_url "your_api_key", options 

    

### Urgency

| Symbol        | Definition          
| :------------- |:-------------
| :immediate  | Responsive action should betaken immediately
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
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Gull is released under the [MIT License](http://www.opensource.org/licenses/MIT).
