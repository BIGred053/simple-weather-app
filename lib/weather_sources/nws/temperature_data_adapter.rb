module WeatherSources
  module NWS
    class TemperatureDataAdapter < WeatherSources::BaseTemperatureDataAdapter
      def initialize(unit, latitude, longitude)
        @unit = unit
        @latitude = latitude
        @longitude = longitude
      end

      def get_current_temperature
        current_weather = WeatherClient.new.get_current_weather(@latitude, @longitude)

        current_temperature_data = current_weather["properties"]["temperature"]

        current_temp = current_temperature_data["value"]

        if current_temperature_data["unitCode"] != "wmoUnit:deg#{@unit}"
          current_temp = convert_temperature_to_desired_unit(current_temp, @unit)
        end

        current_temp.to_f
      end
    end
  end
end
