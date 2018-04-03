require 'pry'

module Hotel
  class Reservation

    RATE = 200.0

    attr_reader :start_date, :end_date, :rooms

    def initialize(input)
      @start_date = input[:start_date]
      @end_date = input[:end_date]
      @rooms = input[:rooms]
    end

    def block?
      false
    end

    def find_total_cost
      length_of_stay = @end_date - @start_date
      length_of_stay * RATE
    end

    def include_room?(room)
      @rooms.include?(room)
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
