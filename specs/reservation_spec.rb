require_relative 'spec_helper'
require 'pry'

describe "Reservation class" do

  describe "initialize method" do
    before do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,3)
      input = {
        :start_date => start_date,
        :end_date => end_date,
        :room => 1,
      }
      @reservation = Hotel::Reservation.new(input)
    end

    it "creates an instance of room" do
      @reservation.must_be_kind_of Hotel::Reservation
    end

    it "is set up for specific attributes and data types" do
      @reservation.start_date.must_be_kind_of Date
      @reservation.end_date.must_be_kind_of Date
      @reservation.room.must_be_kind_of Integer
      @reservation.room.must_equal 1
    end
  end

  describe "find_total_cost method" do
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
    end

    it "returns correct amount when reservation is one night long" do
      reservation = Hotel::Reservation.new (@one_day)
      reservation.find_total_cost.must_equal 200.0
    end

    it "returns correct amount when reservation is many nights long" do
      reservation = Hotel::Reservation.new (@ten_day)
      reservation.find_total_cost.must_equal 2000.0
    end
  end

  describe "include_date?(date) method" do
    before do
      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :room => 1,
      }
      @reservation = Hotel::Reservation.new(ten_day)
    end

    it "returns false if date not included in reservation" do
      date = Date.new(2018,2,1)
      @reservation.include_date?(date).must_equal false
    end

    it "returns true if date included in reservation" do
      date = Date.new(2018,3,8)
      @reservation.include_date?(date).must_equal true
    end

    it "returns false if date equals end date" do
      date = Date.new(2018,3,15)
      @reservation.include_date?(date).must_equal false
    end
  end

  describe "range_conflict?(requested_start, requested_end) method" do
    before do
      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :room => 1,
      }
      @reservation = Hotel::Reservation.new(ten_day)
    end

    it "returns false if requested dates are before reservation dates" do
      requested_start = Date.new(2018,2,5)
      requested_end = Date.new(2018,2,8)
      @reservation.range_conflict?(requested_start, requested_end).must_equal false
    end

    it "returns false if requested dates are after reservation dates" do
      requested_start = Date.new(2018,3,20)
      requested_end = Date.new(2018,3,25)
      @reservation.range_conflict?(requested_start, requested_end).must_equal false
    end

    it "returns false if requested start_date matches reservation end_date" do
      requested_start = Date.new(2018,3,15)
      requested_end = Date.new(2018,3,20)
      @reservation.range_conflict?(requested_start, requested_end).must_equal false
    end

    it "returns true if requested dates and reservation dates have short overlap" do
      requested_start = Date.new(2018,3,1)
      requested_end = Date.new(2018,3,6)
      @reservation.range_conflict?(requested_start, requested_end).must_equal true
    end

    it "returns true if requested dates and reservation dates have long overlap" do
      requested_start = Date.new(2018,3,1)
      requested_end = Date.new(2018,3,13)
      @reservation.range_conflict?(requested_start, requested_end).must_equal true
    end
  end

end
