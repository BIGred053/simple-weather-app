module WeatherSources
  module Errors
    class WeatherDataFetchError < StandardError
      attr_accessor :status_code, :url

      def initialize(status_code:, url:)
        @status_code = status_code
        @url = url
        super
      end
    end
  end
end
