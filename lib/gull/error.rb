require 'English'

module Gull
  class HttpError < StandardError
    attr_reader :original

    def initialize(message, original = $ERROR_INFO)
      super(message)
      @original = original
    end
  end

  class TimeoutError < HttpError
  end
end
