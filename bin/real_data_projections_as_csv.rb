require 'repf'

    def mse(actual, ideal)
      errors = actual.zip(ideal).map {|a, i| a - i }
      ( errors.inject(0) {|sum, err| sum += err**2} ) / errors.length.to_f
    end

    def run_test(outputs, expected_outputs)
      actual_eop = []
      actual_oup = []
      watts_err, errsum = 0, 0
      count = 0

      outputs.each.with_index do |output, i|
        next if output.first.nan? || expected_outputs[i].first.nan?
        next if ( output.first == Float::INFINITY ) || ( expected_outputs[i].first == Float::INFINITY )
        actual_eop << expected_outputs[i]
        actual_oup << output
        watts_err += (output[0] - expected_outputs[i][0]).abs
        errsum += mse(output, expected_outputs[i])
        count += 1
      end

      y_mean = actual_eop.inject(0.0) { |sum, val| sum + val[0] } / actual_eop.size
      y_sum_squares = actual_eop.map{|val| (val[0] - y_mean)**2 }.reduce(:+)
      y_residual_sum_squares = actual_oup.zip(actual_eop).map {|out, expected| (expected[0] - out[0])**2 }.reduce(:+)
      r_squared = 1.0 - (y_residual_sum_squares / y_sum_squares)

      [watts_err / count.to_f, errsum / count.to_f, r_squared]
    end

weather_data = REPF::WeatherData.new( CSV.read('data/camp_elliot_weather_data_92122.csv') ); nil
power_data = REPF::PowerData.new( CSV.read('data/92122_power.csv') ); nil

raw_data = []
raw_data_by_date = Hash.new {|h,k| h[k] = []}
power_data_by_date = {}
scaling_factors = {}

start_time = Time.now

power_data.data.each do |d|
  power_data_by_date[d[:date]] = d
end

weather_data.dates.each do |date|
  d = power_data_by_date[date]
  wd = weather_data.by_date(date)
  todays_power = 0
  wd.each do |w|
    sol = REPF::Solar.new( :capacity => 5040, :insolation => w[:insolation].to_f, :temperature => ( ( w[:temperature].to_f - 32 ) / 1.8 ) )
    raw_data << sol
    raw_data_by_date[date] << sol
    todays_power += sol.instant_power
  end

  scaling_factors[d[:date]] = (d[:power].to_f * 1000)/todays_power if d
end
average_scaling_factor = scaling_factors.values.reject {|n| n == Float::INFINITY}.reject {|n| n > 1}.average

predictor = REPF::SolarPredictor.new(raw_data)
watts_err, avg_mse, r_squared = predictor.train
watts_err, avg_mse, r_squared = predictor.validate

end_time = Time.now

start_time = Time.now

count = 0
today = '2015-2-1'
puts "\nDate,Actual,Predicted\n"
oup = []
eop = []
while Date.parse(today) < Date.parse('2015-02-27')
  actual = (power_data.by_date(today).first[:power].to_f*1000).to_f.round(1)
  begin
    predicted = (raw_data_by_date[Date.parse(today)].inject(0) {|sum,d| sum += predictor.to_watts(predictor.neuralnet.run( predictor.scale_input_and_output(d).first).first)} * scaling_factors[Date.parse(today)]).round(1)
  rescue Exception
    next
  ensure
    today = (Date.parse(today) + 1).to_s
  end
  eop << [actual]
  oup << [predicted]
  puts "#{today},#{actual},#{predicted}"
  count += 1
end
watts_err, avg_mse, r_squared = run_test(oup, eop)
#puts "avg error, rmse, r-squared: #{watts_err}, #{Math.sqrt(avg_mse)}, #{r_squared}"

today = '2014-7-01'
#puts "\nDate\t\t\tActual\t\tPredicted\n"
oup = []
eop = []
while Date.parse(today) < Date.parse('2014-08-10')
  actual = (power_data.by_date(today).first[:power].to_f*1000).to_f.round(1)
  begin
    predicted = (raw_data_by_date[Date.parse(today)].inject(0) {|sum,d| sum += predictor.to_watts(predictor.neuralnet.run( predictor.scale_input_and_output(d).first).first)} * scaling_factors[Date.parse(today)]).round(1)
  rescue Exception
    next
  ensure
    today = (Date.parse(today) + 1).to_s
  end
  eop << [actual]
  oup << [predicted]
  puts "#{today},#{actual},#{predicted}"
  count += 1
end
watts_err, avg_mse, r_squared = run_test(oup, eop)
#puts "avg error, rmse, r-squared: #{watts_err}, #{Math.sqrt(avg_mse)}, #{r_squared}"

#today = '2014-10-01'
#puts "\nDate\t\t\tPredicted\n"
#oup = []
#eop = []
#while Date.parse(today) < Date.parse('2014-11-15')
#  puts "#{today}\t\t#{(raw_data_by_date[Date.parse(today)].inject(0) {|sum,d| sum += predictor.to_watts(predictor.neuralnet.run( predictor.scale_input_and_output(d).first).first)} * average_scaling_factor)}"
#  today = (Date.parse(today) + 1).to_s
#  count += 1
#end

end_time = Time.now

#puts "\nTime to perform and output #{count} output predictions: #{end_time - start_time} seconds."
