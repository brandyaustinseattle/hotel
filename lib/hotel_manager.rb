require 'pry'

module Hotel
  class Administrator

    attr_reader :all_rooms, :all_reservations

    def initialize
      @all_rooms = load_rooms
      @all_reservations = []
    end

    def create_block(requested_start:, requested_end:, group:, discount:, rooms_needed:)

      if rooms_needed > 5
        raiseStandardError("Blocks can't contain more than 5 rooms.")
      end

      rooms_available = @all_rooms.find_all {|room|
          room.available_range?(requested_start, requested_end, nil)}

      if rooms_available.length < rooms_needed
        raiseStandardError("#{rooms_needed} rooms not available on those dates.")
      end

      rooms = rooms_available.take(rooms_needed)

      input = {
        :start_date => requested_start,
        :end_date => requested_end,
        :rooms => rooms,
        :discount => discount,
        :group => group
      }

      block = Hotel::Block.new(input)
      rooms.each {|room| room.add_reservation(block)}
      @all_reservations << block
    end

    def book_any_room(requested_start:, requested_end:, group: nil, guest: nil)

      date_check(requested_start, requested_end)

      chosen_room = @all_rooms.find {|room|
        room.available_range?(requested_start, requested_end, group)}

      raise StandardError("No rooms available. Check start and end dates if reserving a block room.") if chosen_room.nil?

      if group.nil?
        input = {
          :start_date => requested_start,
          :end_date => requested_end,
          :rooms => [chosen_room],
        }

        new_reservation = Hotel::Reservation.new(input)
        chosen_room.add_reservation(new_reservation)
        @all_reservations << new_reservation
      else
        related_reservation = @all_reservations.find {|reservation|
          reservation.start_date == requested_start &&
          reservation.end_date == requested_end &&
          reservation.rooms.include?(chosen_room)}

        related_reservation.assign_guest(chosen_room, guest)
      end
    end

    def book_specific_room(requested_start:, requested_end:, room_num:, group: nil, guest:nil)

      date_check(requested_start, requested_end)

      requested_room = @all_rooms.find { |room| room.room_number == room_num }

      if requested_room.available_range?(requested_start, requested_end, group) == false
        raise StandardError("Room #{room_num} is not available at that time.")
      end

      if group.nil?
        input = {
          :start_date => requested_start,
          :end_date => requested_end,
          :rooms => [requested_room],
        }

        new_reservation = Hotel::Reservation.new(input)
        requested_room.add_reservation(new_reservation)
        @all_reservations << new_reservation
      else
        related_reservation = @all_reservations.find {|reservation|
          reservation.start_date == requested_start &&
          reservation.end_date == requested_end &&
          reservation.rooms.include?(requested_room)}

        related_reservation.assign_guest(requested_room, guest)
      end
    end

    # def find_reservations(date)
    #   @all_reservations.find_all { |reservation|
    #   reservation.include_date?(date) }
    # end
    #
    # # find available rooms not in block
    # def find_rooms(date)
    #   @all_rooms.find_all { |room| room.available_date?(date) }
    # end
    #
    # def find_rooms_in_block(group)
    #   @all_rooms.find_all { |room|
    #   room.reservations() }
    # end

    private

    def load_rooms
      rooms = []
      (1..20).each { |num| rooms << Room.new(num) }
      return rooms
    end

    def date_check(requested_start, requested_end)
      raise StandardError("End date is before start date.") if requested_start > requested_end

    end

  end
end
