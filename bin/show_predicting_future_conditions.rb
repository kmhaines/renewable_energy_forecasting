require 'repf'
require 'repf/predictor/solar'
require 'repf/predictor/wind'

solar_predictors = []
10.times do
  data_size = (60 + ( (rand() * 10).to_i * 30 ) ) # simulate having varying amounts of historical data for each generator
  raw_data = []
  capacity = [200, 240, 500, 1000].shuffle.first # four different potential panel sizes
  data_size.times do
    temp = (rand() * 40).to_i
    raw_data << REPF::Solar.new( :capacity => capacity, :insolation => ( 700 + rand() * 600 ), :temperature => temp, :cloud_cover => ( rand() / 3 ) )
  end

  solar_predictors << REPF::SolarPredictor.new(raw_data)
end

wind_predictors = []
10.times do
  data_size = (60 + ( (rand() * 10).to_i * 30 ) ) # simulate having varying amounts of historical data for each generator
  raw_data = []
  capacity = [300, 400, 600, 1000, 2000].shuffle.first
  data_size.times do
    temp = (rand() * 40).to_i
    raw_data << REPF::Wind.new( :capacity => capacity, :wind => ( rand() * 15 ), :temperature => temp, :dew_point => (5 + ( ( rand() * 18 ).to_i ) ), :air_pressure => ( 98000 + ( ( rand() * 6000).to_i ) ) )
  end

  wind_predictors << REPF::WindPredictor.new(raw_data)
end

print "Training #{solar_predictors.length + wind_predictors.length} predictors..."
solar_predictors.each {|predictor| print "."; predictor.train}
wind_predictors.each {|predictor| print "."; predictor.train}

puts "\n\nValidating predictor training"
solar_errors = []
solar_predictors.each {|predictor| solar_errors << predictor.validate}
wind_errors = []
wind_predictors.each {|predictor| wind_errors << predictor.validate}

averages = ->(ary) do
  watts_err = ary.collect {|x| x[0]}.inject(0) {|sum, v| sum += v; sum} / ary.length 
  mse = ary.collect {|x| x[1]}.inject(0) {|sum, v| sum += v; sum} / ary.length 
  r_square = ary.collect {|x| x[2]}.inject(0) {|sum, v| sum += v; sum} / ary.length 

  [watts_err, mse, r_square]
end

watts_err, avg_mse, r_squared = averages.(solar_errors)
puts "\nAfter training average error rate for solar arrays: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared})\n"

watts_err, avg_mse, r_squared = averages.(wind_errors)
puts "\nAfter training average error rate for wind arrays: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared})\n"

puts "\nNow generate some predictions for future conditions.\n"

# [ temperature, wind, dew_point, air_pressure, cloud_cover, insolation, description ]
conditions = [
  [0, 15, 5, 103500, 0, 950, "cold, windy winter day."],
  [10, 6, 10, 102000, 0.3, 1000, "cool, lightly breezy, damp day."],
  [20, 10, 12, 101000, 0.1, 1050, "pleasant, breezy spring day."],
  [35, 5, 3, 102000, 0, 1100, "sunny, hot, calm, dry summer day."]
]

conditions.each do |condition|
  temperature, wind, dew_point, air_pressure, cloud_cover, insolation, description = condition

  puts "\nCalculating power projections for an hour during a #{description}."

  solar_watts_sum = 0
  solar_predictors.each do |predictor|
    power = predictor.neuralnet.run(
      predictor.scale_input_and_output(
        REPF::Solar.new( :capacity => 1000, :insolation => insolation, :temperature => temperature, :cloud_cover => cloud_cover ) ).first ).first
    solar_watts_sum += predictor.to_watts(power)
  end

  wind_watts_sum = 0
  wind_predictors.each do |predictor|
    power = predictor.neuralnet.run(
      predictor.scale_input_and_output(
        REPF::Wind.new( :capacity => 1000, :wind => wind, :temperature => temperature, :dew_point => dew_point, :air_pressure => air_pressure ) ).first ).first
    wind_watts_sum += predictor.to_watts(power)
  end

  puts "  Total watts generated by solar power during this hour: #{solar_watts_sum}"
  puts "  Total watts generated by wind power during this hour: #{wind_watts_sum}"
end

print "\nSimulating the time required to calculate an entire year's worth of projected power outputs from a wind turbine (365 * 24 = 8736 calculations)..."
start = Time.now
8736.times do |i|
  predictor = wind_predictors.first
  temperature, wind, dew_point, air_pressure, cloud_cover, insolation, description = conditions.first
  power = predictor.neuralnet.run(
    predictor.scale_input_and_output(
      REPF::Wind.new( :capacity => 1000, :wind => wind, :temperature => temperature, :dew_point => dew_point, :air_pressure => air_pressure ) ).first ).first
  print '.' if i % 800 == 0
end
finish = Time.now

puts "\n\n  Finished in #{(finish.to_f - start.to_f).round(3)} seconds."
