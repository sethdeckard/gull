# frozen_string_literal: true

module Gull
  # Holds UGC zone codes and FIPS county codes for an alert area.
  class Geocode
    # @!attribute fips6 [rw] Space-separated FIPS 6 codes
    # @!attribute ugc [rw] Space-separated UGC zone codes
    attr_accessor :fips6, :ugc
  end
end
