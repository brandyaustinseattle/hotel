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

  describe "add_reservation method" do
    before do
      @room = Hotel::Room.new(1)

      @one_day = {
        :start_date => Date.new(2018,3,1),
        :end_date => Date.new(2018,3,2),
        :room => 1,
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
        :room => 1,
      }
      @room.add_reservation(@one_day)
      @room.add_reservation(ten_day)
      @room.reservations.length.must_equal 2
    end
  end

  describe "available_date?(date) method" do
    before do
      @one_day = {
        :start_date => Date.new(2018,3,1),
        :end_date => Date.new(2018,3,2),
        :room => 1,
      }
      @ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :room => 1,
      }
      @room = Hotel::Room.new(1)

      @av_date = Date.new(2018,2,5)
    end

    it "returns true has no reservations" do
      @room.available_date?(@av_date).must_equal true
    end

    it "returns true if room has one reservation, but still available" do
      @room.add_reservation(Hotel::Reservation.new(@one_day))
      @room.available_date?(@av_date).must_equal true
    end

    it "returns true if room has multiple reservation, but still available" do
      @room.add_reservation(Hotel::Reservation.new(@one_day))
      @room.add_reservation(Hotel::Reservation.new(@ten_day))
      @room.available_date?(@av_date).must_equal true
    end

    it "returns false if room has one reservation and is unavailable" do
      @room.add_reservation(Hotel::Reservation.new(@ten_day))
      sample_date = Date.new(2018,3,8)
      @room.available_date?(sample_date).must_equal false
    end

    it "returns false if room has multiple reservations and is unavailable" do
      @room.add_reservation(Hotel::Reservation.new(@one_day))
      @room.add_reservation(Hotel::Reservation.new(@ten_day))
      sample_date = Date.new(2018,3,8)
      @room.available_date?(sample_date).must_equal false
    end
  end













  describe "available_range?(requested_start, requested_end) method" do
    before do
      @room = Hotel::Room.new(1)

      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :room => 1,
      }

      @room.add_reservation(Hotel::Reservation.new(ten_day))
    end

    it "returns true if requested dates are before reservation dates" do
      requested_start = Date.new(2018,2,5)
      requested_end = Date.new(2018,2,8)
      @room.available_range?(requested_start, requested_end).must_equal true
    end

    it "returns true if requested dates are after reservation dates" do
      requested_start = Date.new(2018,3,20)
      requested_end = Date.new(2018,3,25)
      @room.available_range?(requested_start, requested_end).must_equal true
    end

    it "returns true if requested start_date matches reservation end_date" do
      requested_start = Date.new(2018,3,15)
      requested_end = Date.new(2018,3,20)
      @room.available_range?(requested_start, requested_end).must_equal true
    end

    it "returns false if requested dates and reservation dates have short overlap" do
      requested_start = Date.new(2018,3,1)
      requested_end = Date.new(2018,3,6)
      @room.available_range?(requested_start, requested_end).must_equal false
    end

    it "returns false if requested dates and reservation dates have long overlap" do
      requested_start = Date.new(2018,3,1)
      requested_end = Date.new(2018,3,13)
      @room.available_range?(requested_start, requested_end).must_equal false
    end
  end

end
