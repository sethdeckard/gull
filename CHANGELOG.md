#### 0.3.4 (unreleased)
Fixed parser to handle empty geocode.

#### 0.3.3 (11/25/2015)
Handle additional service failure scenarios.
***
#### 0.3.2 (11/10/2015)
Added BadResponseError to client error handling.
***
#### 0.3.1 (6/25/2015)
Added nested error handling for other HTTPClient errors. HttpError has original attribute exposing the root error.
***
#### 0.3.0 (6/23/2015)
Added Client class for error handling (bad entries accessed via errors array). Exposed option to turn on strict XML parsing for debugging. Alert.fetch uses new Client but is backwards compatible, however it doesn't give you access to errors array.
***
#### 0.2.13 (6/20/2015)
Handle missing cap section
***
#### 0.2.12 (6/12/2015)
Fix issue with missing link elements
***
#### 0.2.11 (5/29/2015)
Added method to get original polygon string
***
#### 0.2.10 (3/23/2015)
Added option to override default alert service URI.
***
#### 0.2.1 (10/02/2014)
Added static map image to polygons.
***
#### 0.2.0 (10/02/2014)
Introduced Polygon type.
***
#### 0.1.1 (10/01/2014)
Refactored and simplified alert processing.
***
#### 0.1.0 (10/01/2014)
Initial release, basic functionality of fetching and parsing alerts.
