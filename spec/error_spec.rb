require 'spec_helper'

describe Gull::HttpError do
  it 'should instantiate and set original with current exception' do
    error = StandardError.new 'inner'
    begin
      fail error
    rescue StandardError
      http_error = Gull::HttpError.new 'test'
      expect(http_error.original).to eq error
      expect(http_error.original.message). to eq 'inner'
    end
  end
end
