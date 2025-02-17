module WeatherDataBuilders
  class TemperatureDataBuilder
    def self.build(unit, latitude, longitude)
      nws_adapter = WeatherSources::NWS::TemperatureDataAdapter.new(unit, latitude, longitude)

      {
        current_temperature: nws_adapter.get_current_temperature
      }
    end
  end
end
