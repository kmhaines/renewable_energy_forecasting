require 'repf/generator'

module REPF
  class Wind < Generator

    attr_accessor :wind, :cutin, :feathering_cutin, :feathered_output, :rated_peak_wind, :temperature, :dew_point, :air_pressure, :swept_area

    # metric measurements for all.

    DEFAULT_WIND = 4.5
    DEFAULT_CUTIN = 4.5
    DEFAULT_FEATHERING_CUTIN = 18
    DEFAULT_FEATHERED_OUTPUT = 0.5
    DEFAULT_RATED_PEAK_WIND = 16
    DEFAULT_TEMPERATURE = 20
    DEFAULT_SWEPT_AREA = 1
    DEFAULT_DEW_POINT = 0
    DEFAULT_AIR_PRESSURE = 102000

    def self.mph_to_meters_per_second(mph)
      #  miles_per_hour * ( 5280_feet_per_mile / 3600_seconds_per_hour ) * 0.3048_meters_per_foot
      #  mph * ( 5280 / 3600 ) * 0.3048
      mph * 0.44704 
    end

    def initialize(*args)
      super

      args =
        {:wind => DEFAULT_WIND,
         :cutin => DEFAULT_CUTIN,
         :feathering_cutin => DEFAULT_FEATHERING_CUTIN,
         :feathered_output => DEFAULT_FEATHERED_OUTPUT,
         :rated_peak_wind => DEFAULT_RATED_PEAK_WIND,
         :temperature => DEFAULT_TEMPERATURE,
         :dew_point => DEFAULT_DEW_POINT,
         :air_pressure => DEFAULT_AIR_PRESSURE,
         :swept_area => DEFAULT_SWEPT_AREA} if args.empty?
    
      if Hash === args.first
        args = args.first
      elsif Array === args
        args = args.even.zip(args.odd)
      end

      self.wind = args[:wind] || DEFAULT_WIND
      self.cutin = args[:cutin] || DEFAULT_CUTIN
      self.feathering_cutin = args[:feathering_cutin] || DEFAULT_FEATHERING_CUTIN
      self.feathered_output = args[:feathered_output] || DEFAULT_FEATHERED_OUTPUT
      self.rated_peak_wind = args[:rated_peak_wind] || DEFAULT_RATED_PEAK_WIND
      self.temperature = args[:temperature] || DEFAULT_TEMPERATURE
      self.dew_point => args[:dew_point] || DEFAULT_DEW_POINT
      self.air_pressure => args[:air_pressure] || DEFAULT_AIR_PRESSURE
      self.swept_area = args[:swept_area] || DEFAULT_SWEPT_AREA
    end

    def total_available_power(w = wind)
      0.5 * air_density * swept_area * w
    end

    def efficiency_at_peak
      capacity / total_available_power( rated_peak_wind )
    end

    def instant_power
      wind < cutin ? 0 : total_available_power * efficiency_at_peak
    end

    def air_density
      p = air_pressure + water_vapor_pressure
      ( p / ( 287.05 * temperature_in_kelvin ) ) * ( 1 - ( ( 0.378 * water_vapor_pressure ) / p ) )
    end

    def water_vapor_pressure(t = temperature)
      6.1078 *10**( ( 7.5 * t ) / ( 237.3 + t ) )
    end

    def temperature_in_kelvin(celcius = temperature)
      273.15 + celcius
    end
  end
end
