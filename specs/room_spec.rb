require_relative 'spec_helper'
require 'pry'

describe "Room class" do

  describe "initialize method" do
    before do
      @room = Hotel::Room.new(1)
    end

    it "creates an instance of room" do
      @room.must_be_kind_of Hotel::Room
    end

    it "is set up for specific attributes and data types" do
      @room.room_number.must_be_kind_of Integer
      @room.room_number.must_equal 1
      @room.reservations.must_be_kind_of Array
      @room.reservations.empty?.must_equal true
    end
  end

  describe "add_reservation method - general reservations" do
    before do
      @room = Hotel::Room.new(1)

      @one_day = {
        :start_date => Date.new(2018,3,1),
        :end_date => Date.new(2018,3,2),
        :rooms => [@room]
      }
    end

    it "adds reservation when one reservation" do
      @room.add_reservation(@one_day)
      @room.reservations.length.must_equal 1
    end

    it "adds reservation when multiple resrvations" do
      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room]
      }
      @room.add_reservation(@one_day)
      @room.add_reservation(ten_day)
      @room.reservations.length.must_equal 2
    end
  end

  describe "add_reservation method - block reservations" do
    before do
      @room_one = Hotel::Room.new(1)
      @room_two = Hotel::Room.new(2)

      input = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room_one, @room_two],
        :discount => 0.10,
        :group => "Sonics"
      }
      @first_block = Hotel::Block.new(input)
    end

    it "adds block when one block" do
      @room_one.add_reservation(@first_block)
      @room_one.reservations.length.must_equal 1

      @room_two.add_reservation(@first_block)
      @room_two.reservations.length.must_equal 1
    end

    it "adds block when multiple blocks" do
      input = {
        :start_date => Date.new(2018,3,18),
        :end_date => Date.new(2018,3,20),
        :group => "Spurs",
        :discount => 0.10,
        :rooms => [@room_one, @room_two]
      }
      second_block = Hotel::Block.new(input)

      @room_one.add_reservation(@first_block)
      @room_one.add_reservation(second_block)
      @room_one.reservations.length.must_equal 2

      @room_two.add_reservation(@first_block)
      @room_two.add_reservation(second_block)
      @room_two.reservations.length.must_equal 2
    end
  end

  describe "available_date?(date, group) method - general public requesting with gen reservation in place" do
    before do
      @room = Hotel::Room.new(1)
      @av_date = Date.new(2018,2,5)

      @one_day = {
        :start_date => Date.new(2018,3,1),
        :end_date => Date.new(2018,3,2),
        :rooms => [@room]
      }
      @ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room]
      }
    end

    it "returns true has if it has no reservations" do
      @room.available_date?(@av_date, nil).must_equal true
    end

    it "returns true if room has one reservation, but still available" do
      @room.add_reservation(Hotel::Reservation.new(@one_day))
      @room.available_date?(@av_date, nil).must_equal true
    end

    it "returns true if room has multiple reservation, but still available" do
      @room.add_reservation(Hotel::Reservation.new(@one_day))
      @room.add_reservation(Hotel::Reservation.new(@ten_day))
      @room.available_date?(@av_date, nil).must_equal true
    end

    it "returns false if room has one reservation and is unavailable" do
      @room.add_reservation(Hotel::Reservation.new(@ten_day))
      sample_date = Date.new(2018,3,8)
      @room.available_date?(sample_date, nil).must_equal false
    end

    it "returns false if room has multiple reservations and is unavailable" do
      @room.add_reservation(Hotel::Reservation.new(@one_day))
      @room.add_reservation(Hotel::Reservation.new(@ten_day))
      sample_date = Date.new(2018,3,8)
      @room.available_date?(sample_date, nil).must_equal false
    end
  end

  describe "available_date?(date, group) method - general public requesting with block reservation in place" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room, @extra_room],
        :discount => 0.10,
        :group => "Sonics"
      }

      @block = Hotel::Block.new(input)
      @room.add_reservation(@block)
      @extra_room.add_reservation(@block)

      @av_date = Date.new(2018,2,5)
    end

    it "returns true if room has block, but still available" do
      @room.available_date?(@av_date, nil).must_equal true
    end


    it "returns true if room has block that ends on request_date" do
      @room.available_date?(Date.new(2018,3,15), nil).must_equal true
    end

    it "returns false if room has one block and not available" do
      @room.available_date?(Date.new(2018,3,8), nil).must_equal false
    end
  end

  describe "available_date?(date, group) method - block guest requesting" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room, @extra_room],
        :discount => 0.10,
        :group => "Sonics"
      }

      @block = Hotel::Block.new(input)
      @room.add_reservation(@block)

      @date = Date.new(2018,3,8)
    end

    it "returns true if room available in requested block" do
      @room.available_date?(@date, "Sonics").must_equal true
    end

    it "returns false if room not available in requested block because guest has taken it already" do
      @block.assign_guest(@room, "Gary Payton")
      @room.available_date?(@date, "Sonics").must_equal false
    end

    it "returns false if room not available in requested block because block doesn't exist for that group" do
      @room.available_date?(@date, "Celtics").must_equal false
    end
  end

  describe "available_range?(start_date, end_date) method - general public requesting with gen reservation in place" do
    before do
      @room = Hotel::Room.new(1)

      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room]
      }

      @room.add_reservation(Hotel::Reservation.new(ten_day))
    end

    it "raises error if start_date after end_date" do
      proc{ @room.available_range?(Date.new(2018,3,2), Date.new(2018,3,1), nil).must_raise StandardError }
    end

    it "returns true if requested dates are before reservation dates" do
      start_date = Date.new(2018,2,5)
      end_date = Date.new(2018,2,8)
      @room.available_range?(start_date, end_date, nil).must_equal true
    end

    it "returns true if requested dates are after reservation dates" do
      start_date = Date.new(2018,3,20)
      end_date = Date.new(2018,3,25)
      @room.available_range?(start_date, end_date, nil).must_equal true
    end

    it "returns true if requested start_date matches reservation end_date" do
      start_date = Date.new(2018,3,15)
      end_date = Date.new(2018,3,20)
      @room.available_range?(start_date, end_date, nil).must_equal true
    end

    it "returns false if requested dates and reservation dates have short overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,6)
      @room.available_range?(start_date, end_date, nil).must_equal false
    end

    it "returns false if requested dates and reservation dates have long overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,13)
      @room.available_range?(start_date, end_date, nil).must_equal false
    end
  end

  describe "available_range?(start_date, end_date) method - general public requesting with block reservation in place" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room, @extra_room],
        :discount => 0.10,
        :group => "Sonics"
      }

      @block = Hotel::Block.new(input)
      @room.add_reservation(@block)
      @extra_room.add_reservation(@block)
    end

    it "raises error if start_date after end_date" do
      proc{ @room.available_range?(Date.new(2018,3,2), Date.new(2018,3,1), nil).must_raise StandardError }
    end

    it "returns true if requested dates are before reservation dates" do
      start_date = Date.new(2018,2,5)
      end_date = Date.new(2018,2,8)
      @room.available_range?(start_date, end_date, nil).must_equal true
    end

    it "returns true if requested dates are after reservation dates" do
      start_date = Date.new(2018,3,20)
      end_date = Date.new(2018,3,25)
      @room.available_range?(start_date, end_date, nil).must_equal true
    end

    it "returns true if requested start_date matches reservation end_date" do
      start_date = Date.new(2018,3,15)
      end_date = Date.new(2018,3,20)
      @room.available_range?(start_date, end_date, nil).must_equal true
    end

    it "returns false if requested dates and reservation dates have short overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,6)
      @room.available_range?(start_date, end_date, nil).must_equal false
    end

    it "returns false if requested dates and reservation dates have long overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,13)
      @room.available_range?(start_date, end_date, nil).must_equal false
    end
  end

  describe "available_range?(requested_start, requested_end) method - block guest requesting" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room, @extra_room],
        :discount => 0.10,
        :group => "Sonics"
      }

      @block = Hotel::Block.new(input)
      @room.add_reservation(@block)

      @requested_start = Date.new(2018,3,5)
      @requested_end = Date.new(2018,3,15)
    end

    it "returns true if room available in requested block" do
      @room.available_range?(@requested_start, @requested_end, "Sonics").must_equal true
    end

    it "returns false if dates requested don't match block dates" do
      requested_end = Date.new(2018,3,10)
      @room.available_range?(@requested_start, requested_end, "Sonics").must_equal false
    end

    it "returns false if room not available in requested block because guest has taken it already" do
      @block.assign_guest(@room, "Gary Payton")
      @room.available_range?(@requested_start, @requested_end, "Sonics").must_equal false
    end

    it "returns false if room not available in requested block because block doesn't exist for that group" do
      @room.available_range?(@requested_start, @requested_end, "Celtics").must_equal false
    end
  end

end
