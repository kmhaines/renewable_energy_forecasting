require 'digest/sha1'

 module REPF
  class Generator

    FIXNUM_MAX = (2**(0.size * 8 -2) -1)
    FIXNUM_MIN = -(2**(0.size * 8 -2))

    # Superclass for all power generation models. This class assumes a basic interface
    # that defines all power generation models to have a max generating capacity, in watts,
    # a typical efficiency of power generation, expressed as a percentage, and a typical
    # timespan of generation per day, in hours. The interface provides for methods to
    # return an instant_power, which is defined as max capacity time efficiency, and
    # a power over time, which is defined as the instant power, times the time span,
    # time a variation, which will simulate power levels varying over time.
    attr_accessor :capacity, :efficiency, :input, :timespan, :q

    DEFAULT_CAPACITY = 100
    DEFAULT_EFFICIENCY = 1
    DEFAULT_TIMESPAN = 10
    DEFAULT_Q = 1

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
      self.q = args[:q] || 0
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

    def q_factor
      1 + q
    end

    def to_s
      "capacity:#{capacity};efficiency:#{efficiency}"
    end

    def to_a
      [capacity, efficiency]
    end

    def hash
      puts "hashing from #{to_s}"
      ( Digest::SHA1.hexdigest(to_s).to_s.to_i(16) % (FIXNUM_MAX * 2 + 1) ) + FIXNUM_MIN
    end

  end
end
