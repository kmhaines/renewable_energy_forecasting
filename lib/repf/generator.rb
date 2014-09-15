module REPF
  class Generator
    # Superclass for all power generation models. This class assumes a basic interface
    # that defines all power generation models to have a max generating capacity, in watts,
    # a typical efficiency of power generation, expressed as a percentage, and a typical
    # timespan of generation per day, in hours. The interface provides for methods to
    # return an instant_power, which is defined as max capacity time efficiency, and
    # a power over time, which is defined as the instant power, times the time span,
    # time a variation, which will simulate power levels varying over time.
    attr_accessor :capacity, :efficiency, :input, :timespan

    DEFAULT_CAPACITY = 100
    DEFAULT_EFFICIENCY = 1
    DEFAULT_TIMESPAN = 10

    def initialize(*args)
      args = {:capacity => 100, :efficiency => 1, :timespan => 10} if args.empty?
    
      if Hash === args.first
        args = args.first
      elsif Array === args
        args = args.even.zip(args.odd)
      end

      self.capacity = args[:capacity] || 100
      self.efficiency = args[:efficiency] || 1
      self.timespan = args[:timespan] || 10
    end

    def instant_power
      capacity * efficiency
    end

    def power_over_time(ts = timespan)
      instant_power * ts * ( Array.new( timespan / 4 ) { variation }.average )
    end

    def variation
      1
    end

  end
end
