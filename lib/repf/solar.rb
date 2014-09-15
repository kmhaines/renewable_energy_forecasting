require 'repf/generator'

module REPF
  class Solar < Generator

    attr_accessor :insolation, :cloud_cover

    DEFAULT_INSOLATION = 1000
    DEFAULT_CLOUD_COVER = 0

    def initialize(*args)
      super

      args = {:insolation => DEFAULT_INSOLATION, :cloud_cover => DEFAULT_CLOUD_COVER} if args.empty?
    
      if Hash === args.first
        args = args.first
      elsif Array === args
        args = args.even.zip(args.odd)
      end

      self.insolation = args[:insolation] || DEFAULT_INSOLATION
      self.cloud_cover = args[:cloud_cover] || DEFAULT_CLOUD_COVER
    end

    def instant_power
      capacity * (insolation / 1000) * (1 - cloud_cover)
    end

    def variation
      0.975 + ( rand() * 0.05)
    end

  end
end
