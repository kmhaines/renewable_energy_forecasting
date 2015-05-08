require 'repf'
require 'repf/predictor/solar'
require 'csv'
require 'date'

module REPF

  class GenericData
    attr_accessor :data

    def initialize( csv )
      @data = to_array_of_hashes( clean( csv ) )
      @data_by_date = {}
    end

    def dates
      @data.collect {|dx| dx[:date]}.sort.uniq
    end

    def by_date(d)
      dd = Date === d ? d : Date.parse(d)

      if @data_by_date.has_key? dd
        @data_by_date[dd]
      else
        @data_by_date[dd] = @data.select {|dx| dx[:date] == dd}
      end
    end

    def clean( csv )
      csv.reject do |row|
        row.first =~ /^\s*\#/
      end.reject do |row|
        row.empty?
      end.collect do |row|
        row.collect {|item| String === item ? item.strip : item}
      end
    end

    def to_array_of_hashes( information )
      @fields = decode_field_abbreviations information.first

      new_fields = []

      information[1..-1].each do |row|
        next if row.length != @fields.length

        structure = { :date => date_from_data( row ) }.merge( data_as_hash( row ) ) { |key, oldval, newval| oldval }
        new_fields << structure
      end

      new_fields
    end

    private

    def date_from_data row
      if @fields.index( :date )
        date_representation = row[@fields.index :date]
      else
        year = row[@fields.index :year]
        month = row[@fields.index :month]
        day = row[@fields.index :day]
        date_representation = "#{year}-#{month}-#{day}"
      end

      Date.parse( date_representation )
    end

    def data_as_hash row
      h = {}
      @fields.each do |f|
        case f
        when :year, :month, :day
          next
        else
          h[f] = row[ @fields.index f ]
        end
      end

      h
    end

    def decode_field_abbreviations(fields)
      fields.collect {|f| field_abbreviation_to_symbol f.downcase}
    end

    def field_abbreviation_to_symbol(field)
      case field.to_s
      when 'mon'
        :month
      when 'hr'
        :hour
      when 'min'
        :minute
      when 'tmzn'
        :timezone
      when 'tmpf'
        :temperature
      when 'relh'
        :relative_humidity
      when 'sknt'
        :wind_speed
      when 'gust'
        :wind_gust
      when 'drct'
        :wind_direction
      when 'solr'
        :insolation
      when 'peak'
        :wind_peak_speed
      when 'prec'
        :precipitation
      when 'dwpf'
        :dewpoint
      else
        field.to_sym
      end
    end

  end

  class PowerData < GenericData
  end

  class WeatherData < GenericData
  end

end
