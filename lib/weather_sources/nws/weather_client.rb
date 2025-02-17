module WeatherSources
  module NWS
    class WeatherClient
      NWS_API_BASE_URL = "https://api.weather.gov"

      def initialize(http_conn = nil)
        @http_conn = http_conn || Faraday.new(NWS_API_BASE_URL)
      end

      def get_current_weather(latitude, longitude)
        weather_office_data = fetch_office_id_and_point_from_coordinates(latitude, longitude)

        station_id = fetch_station_for_coordinates(weather_office_data)

        fetch_latest_station_reading(station_id)
      rescue WeatherSources::Errors::WeatherDataFetchError => e
        Rails.logger.error("Failed to fetch weather data at URL: #{e.url}. Status: #{e.status_code}")
        raise e
      end

      private

      def fetch_office_id_and_point_from_coordinates(latitude, longitude)
        trimmed_lat = trim_coordinate(latitude)
        trimmed_lon = trim_coordinate(longitude)
        point_data = get("/points/#{trimmed_lat},#{trimmed_lon}")

        {
          office_id: point_data["properties"]["gridId"],
          office_x: point_data["properties"]["gridX"],
          office_y: point_data["properties"]["gridY"]
        }
      end

      def trim_coordinate(coordinate)
        "%.4f" % coordinate
      end

      def get(route)
        response = @http_conn.get(route)

        if response.status == 200
          JSON.parse(response.body)
        else
          raise WeatherSources::Errors::WeatherDataFetchError.new(
            status_code: response.status,
            url: "#{NWS_API_BASE_URL}#{route}"
          )
        end
      end

      def fetch_station_for_coordinates(office_data)
        stations_route =
          "/gridpoints/#{office_data[:office_id]}/#{office_data[:office_x]},#{office_data[:office_y]}/stations"

        stations_data = get(stations_route)

        stations_data["features"].first["properties"]["stationIdentifier"]
      end

      def fetch_latest_station_reading(station_id)
        get("stations/#{station_id}/observations/latest")
      end
    end
  end
end
