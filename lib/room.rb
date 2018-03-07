require 'pry'

module Hotel
  class Room

    attr_reader :room_number, :reservations

    def initialize(num)
      @room_number = num
      @reservations = []
    end

    def add_reservation(reservation)
      reservations << reservation
    end

    def available_date?(date)
        # date = Date.new(date) if date.class != Date

        @reservations.none? {|reservation|
          reservation.include_date?(date)
        }
    end

    def available_range?(requested_start, requested_end)
        requested_start = Date.new(requested_start) if requested_start.class != Date
        requested_end = Date.new(requested_start) if requested_end.class != Date

        @reservations.none? {|reservation|
          reservation.range_conflict?(requested_start, requested_end)
        }
    end

  end
end
