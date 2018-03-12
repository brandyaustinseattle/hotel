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

    def available_date?(date, group)
      if group.nil?
        @reservations.none? { |reservation|
          reservation.include_date?(date)
        }
      else
        @reservations.any? { |reservation|
          reservation.include_date?(date) &&
            reservation.block? &&
            reservation.group == group &&
            reservation.guest_list[self] == nil
        }
      end
    end

    def available_range?(requested_start, requested_end, group)
      if group.nil?
        @reservations.none? { |reservation|
          reservation.range_conflict?(requested_start, requested_end)
        }
      else
        @reservations.any? { |reservation|
          reservation.block? &&
            reservation.group == group &&
            reservation.guest_list[self] == nil &&
            reservation.range_match?(requested_start, requested_end)
        }
        # requested start and end must match days of the block
        # guest can't request room in block for partial period
      end
    end

  end
end
