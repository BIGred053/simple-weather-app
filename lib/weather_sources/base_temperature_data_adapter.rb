module WeatherSources
  class BaseTemperatureDataAdapter
    private

    def convert_temperature_to_desired_unit(temperature_string, desired_unit)
      case desired_unit
      when "F"
        celsius_to_fahrenheit(temperature_string)
      when "C"
        fahrenheit_to_celsius(temperature_string)
      end
    end

    def celsius_to_fahrenheit(temperature_string)
      (temperature_string.to_f * 1.8) + 32
    end

    def fahrenheit_to_celsius(temperature_string)
      (temperature_string.to_f - 32) * (5/9)
    end
  end
end
