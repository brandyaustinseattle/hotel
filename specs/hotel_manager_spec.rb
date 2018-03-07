require_relative 'spec_helper'
require 'pry'

describe "Reservation class" do
  before do
    @administrator = Hotel::Administrator.new
  end

  describe "initialize method" do
    it "creates an instance of administrator" do
      @administrator.must_be_kind_of Hotel::Administrator
    end

    it "is set up for specific attributes and data types" do
      @administrator.all_rooms.must_be_kind_of Array
      @administrator.all_rooms.length.must_equal 20
      @administrator.all_reservations.must_be_kind_of Array
      @administrator.all_reservations.empty?.must_equal true
    end
  end

  describe "reserve_room method" do

    it "accepts user input for requested_start and requested_end" do
      !@administrator.reserve_room("3-1-2018", "3-5-2018").must_raise StandardError
    end

    it "adds a reservation to @all_reservations" do
      @administrator.reserve_room("3-1-2018", "3-5-2018")
      @administrator.all_reservations.length.must_equal 1
    end

    it "adds a reservation to the room instance" do
      @administrator.reserve_room("3-1-2018", "3-5-2018")
      rooms = @administrator.all_rooms
      rooms[0].reservations.length.must_equal 1
    end

    it "adds a reservation to the room instance" do
      @administrator.reserve_room("3-1-2018", "3-5-2018")
      rooms = @administrator.all_rooms
      rooms[0].reservations.length.must_equal 1
    end
  end

  describe "find_reservations method" do
    it "returns one reservation when there's one on that date and one total" do
      @administrator.reserve_room("2018-3-5", "2018-3-15")
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,8))

      applicable_reservations.length.must_equal 1
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,5)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,15)

    end

    it "returns one reservation when there's one on that date and many total" do
      @administrator.reserve_room("2018-3-5", "2018-3-15")
      @administrator.reserve_room("2018-3-2", "2018-3-8")
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,3))

      applicable_reservations.length.must_equal 1
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,2)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,8)
    end

    it "returns many reservations when there's many on that date" do
      @administrator.reserve_room("2018-3-5", "2018-3-15")
      @administrator.reserve_room("2018-3-2", "2018-3-8")
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,6))

      applicable_reservations.length.must_equal 2
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,5)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,15)
      applicable_reservations[1].start_date.must_equal Date.new(2018,3,2)
      applicable_reservations[1].end_date.must_equal Date.new(2018,3,8)
    end

    it "returns empty_array when there's no reservations on that date" do
      @administrator.find_reservations(Date.new(2018,5,1)).empty?.must_equal true
    end
  end

  describe "find_rooms(date) method" do

    before do
      @ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15)
      }
    end

    it "returns all rooms when all available" do
      available_rooms = @administrator.find_rooms(Date.new(2018,3,1))

      available_rooms.length.must_equal 20
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 1
    end

    it "returns many rooms when many rooms available" do
      @ten_day[:room] = 1
      reservation = Hotel::Reservation.new(@ten_day)
      this_room = @administrator.all_rooms.find {|room| room.room_number == 1}
      this_room.add_reservation(reservation)

      available_rooms = @administrator.find_rooms(Date.new(2018,3,10))

      available_rooms.length.must_equal 19
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 2
    end

    it "returns one room when one room available" do
      (1..19).each {|num|
        @ten_day[:room] = num
        reservation = Hotel::Reservation.new(@ten_day)
        this_room = @administrator.all_rooms.find {|room| room.room_number == num}
        this_room.add_reservation(reservation)
      }

      available_rooms = @administrator.find_rooms(Date.new(2018,3,10))

      available_rooms.length.must_equal 1
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 20
    end

    it "returns empty array when no rooms available" do
      (1..20).each {|num|
        @ten_day[:room] = num
        reservation = Hotel::Reservation.new(@ten_day)
        this_room = @administrator.all_rooms.find {|room| room.room_number == num}
        this_room.add_reservation(reservation)
      }

      available_rooms = @administrator.find_rooms(Date.new(2018,3,10))

      available_rooms.empty?.must_equal true
    end
  end

end
