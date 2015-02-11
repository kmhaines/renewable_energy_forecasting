require 'repf/generator'

module REPF
  class Solar < Generator

    attr_accessor :insolation, :cloud_cover, :temperature

    DEFAULT_INSOLATION = 1000
    DEFAULT_CLOUD_COVER = 0
    DEFAULT_AMBIENT_TEMPERATURE = 20

    def initialize(*args)
      super

      args = {
        :insolation => DEFAULT_INSOLATION,
        :cloud_cover => DEFAULT_CLOUD_COVER,
        :temperature => DEFAULT_AMBIENT_TEMPERATURE
      } if args.empty?

      if Hash === args.first
        args = args.first
      elsif Array === args
        args = args.even.zip(args.odd)
      end

      self.insolation = args[:insolation] || DEFAULT_INSOLATION
      self.cloud_cover = args[:cloud_cover] || DEFAULT_CLOUD_COVER
      self.temperature = args[:temperature] || DEFAULT_AMBIENT_TEMPERATURE
    end

    def instant_power
      capacity * ( insolation / 1000 ) * ( 1 - cloud_cover ) * temperature_adjustment * q_factor
    end

    def temperature_adjustment
      # This algorithm is not ideal. Taken from information at http://www.reuk.co.uk/Effect-of-Temperature-on-Solar-Panels.htm
      # There has to be a better algorithm somewhere, but this is probably good enough to generate experimental data.
      # Assumes that exposed panel temperatures are going to run 10 degrees celcius warmer than the ambient temperature.
      if temperature >= 31
        # A drop of 1.1% of power output from an extrapolated panel temperature of 42 degrees or higher.
        1 - ( ( temperature - 30 ) * 0.011 )
      else
        1
      end
    end

    def to_s
      "capacity:#{capacity};insolation:#{insolation};cloudcover:#{cloud_cover};temperature:#{temperature}"
    end

    def to_a
      [capacity, insolation, cloud_cover, temperature]
    end

  end
end
