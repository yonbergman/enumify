require 'spec_helper'

class Model < ActiveRecord::Base
  extend Enumify::Model

  enum :status, [:available, :canceled, :completed]
end

class OtherModel < ActiveRecord::Base
  extend Enumify::Model

  belongs_to :model

  enum :status, [:active, :expired]
end

describe :Enumify do

  before(:each) do
    Model.delete_all
    OtherModel.delete_all

    @obj = Model.create!(:status => :available)
    @canceled_obj = Model.create!(:status => :canceled)
    @completed_obj = Model.create!(:status => :completed)

    @active_obj = OtherModel.create!(:status => :active, :model => @obj)
    @expired_obj = OtherModel.create!(:status => :expired, :model => @canceled_obj)
  end

  describe "short hand methods" do
    describe "question mark (?)" do
      it "should return true if value of enum equals a value" do
        @obj.available?.should be_true
      end

      it "should return false if value of enum is different " do
        @obj.canceled?.should be_false
      end

    end

    describe "exclemation mark (!)" do
      it "should change the value of the enum to the methods value" do
        @obj.canceled!
        @obj.status.should == :canceled
      end
    end

    it "should have two shorthand methods for each possible value" do
      Model::STATUSES.each do |val|
        @obj.respond_to?("#{val}?").should be_true
        @obj.respond_to?("#{val}!").should be_true
      end
    end
  end

  describe "getting value" do
    it "should always return the enums value as a symbol" do
      @obj.status.should == :available
      @obj.status = "canceled"
      @obj.status.should == :canceled
    end

  end

  describe "setting value" do
    it "should except values as symbol" do
      @obj.status = :canceled
      @obj.canceled?.should be_true
    end

    it "should except values as string" do
      @obj.status = "canceled"
      @obj.canceled?.should be_true
    end
  end

  describe "validations" do
    it "should not except a value outside the given list" do
      @obj = Model.new(:status => :available)
      @obj.status = :foobar
      @obj.should_not be_valid
    end

    it "should except value in the list" do
      @obj = Model.new(:status => :available)
      @obj.status = :canceled
      @obj.should be_valid
    end
  end

  describe "callbacks" do
    it "should receive a callback on change of value" do
      @obj.should_receive(:status_changed).with(:available,:canceled)
      @obj.canceled!
    end

    it "should not receive a callback on initial value" do
      @obj = Model.new
      @obj.should_not_receive(:status_changed).with(nil, :canceled)
      @obj.canceled!
      end

    it "should not receive a callback on value change to same" do
      @obj.should_not_receive(:status_changed).with(:available, :available)
      @obj.available!
    end

  end

  describe "scopes" do
    it "should return objects with given value" do
      Model.available.should == [@obj]
      Model.canceled.should == [@canceled_obj]
    end

    it "should return objects with given value when joined with models who have the same enum field" do
      OtherModel.joins(:model).active.should == [@active_obj]
    end

    describe "negation scopes" do

      it "should return objects that do not have the given value" do
        Model.not_available.should include(@canceled_obj, @completed_obj)
      end

      it "should return objects that do not have the given value when joined with models who have the same enum field" do
        OtherModel.joins(:model).not_active.should == [@expired_obj]
      end
    end

  end


  it "class should have a CONST that holds all the available options of the enum" do
    Model::STATUSES.should == [:available, :canceled, :completed]
  end

end