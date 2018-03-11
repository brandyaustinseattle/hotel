require 'pry'

module Hotel
  class Room

    attr_reader :room_number, :reservations, :blocks

    def initialize(num)
      @room_number = num
      @reservations = []
      @blocks = []
    end

    def add_reservation(reservation)
      reservations << reservation
    end

    def add_block(block)
      blocks << block
    end

    def available_date?(date, group: nil)
      block_check = @blocks.none? { |block|
        block.include_date?(date)
      }

      res_check = @reservations.none? { |reservation|
        reservation.include_date?(date)
      }

      block_no_guest = @blocks.any? { |block|
        block.include_date?(date) && block.group == group && block.guest.nil?
      }

      group.nil? ? block_check && res_check : block_no_guest
    end

    def available_range?(requested_start, requested_end, group: nil)
      if requested_start > requested_end
        raiseStandardError("Start date is after end date.")
      end

      block_check = @blocks.none? { |block|
        block.range_conflict?(requested_start, requested_end)
      }

      res_check = @reservations.none? { |reservation|
        reservation.range_conflict?(requested_start, requested_end)
      }

      block_no_guest = @blocks.any? { |block|
        block.range_conflict?(requested_start, requested_end) && block.group == group && block.guest.nil?
      }

      group.nil? ? block_check && res_check : block_no_guest
    end
  end

end
