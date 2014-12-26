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
      capacity * (insolation / 1000) * (1 - cloud_cover) * variation
    end

    def variation
      0.975 + ( rand() * 0.05)
    end

  end
end
