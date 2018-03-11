require 'pry'

module Hotel
  class Block

    attr_reader :start_date, :end_date, :party, :discount, :rooms

    def initialize(input)
      @start_date = input[:requested_start]
      @end_date = input[:requested_end]
      @party = input[:party]
      @discount = input[:discount]
      @rooms = input[:rooms]
    end

    def include_date?(date)
      @start_date < date && @end_date > date
    end

    def range_conflict?(requested_start, requested_end)
      return false if @start_date > requested_start && @start_date >= requested_end
      return false if @end_date <= requested_start && @end_date < requested_end

      return true
    end

  end
end
