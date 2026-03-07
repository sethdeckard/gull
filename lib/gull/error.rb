# frozen_string_literal: true

require 'English'

module Gull
  # Raised when the NWS API returns a non-success response or the
  # connection fails. Wraps the original exception, if any.
  class HttpError < StandardError
    attr_reader :original

    def initialize(message, original = $ERROR_INFO)
      super(message)
      @original = original
    end
  end

  # Raised when the NWS API request times out.
  class TimeoutError < HttpError
  end
end
