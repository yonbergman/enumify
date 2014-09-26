require 'spec_helper'

class Model < ActiveRecord::Base
  include Enumify::Model

  enum :status, [:available, :canceled, :completed]
end

class OtherModel < ActiveRecord::Base
  include Enumify::Model

  belongs_to :model

  enum :status, [:active, :expired, :not_expired]
end

class ModelAllowingNil < ActiveRecord::Base
  include Enumify::Model
  self.table_name = 'models'
  enum :status, [:available, :canceled, :completed], :allow_nil => true
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
    @not_expired_obj = OtherModel.create!(:status => :not_expired, :model => @canceled_obj)
  end

  describe "allow nil" do

    before(:each) do
      @obj_not_allowing_nil = Model.create
      @obj_allowing_nil = ModelAllowingNil.create
    end

    describe "model allowing enum value to be nil" do
      subject { @obj_allowing_nil }
      it "should be valid" do
        expect(subject).to be_valid
      end

      it 'should not raise error when setting value to nil' do
        expect {
          subject.status = nil
        }.to_not raise_error

        expect(subject.status).to be_nil
      end
    end

    describe "model not allowing enum value to be nil" do
      subject { @obj_not_allowing_nil }
      it "should be invalid" do
        expect(subject).to be_invalid
      end

      it 'should not raise error when setting value to nil' do
        expect {
          subject.status = nil
        }.to_not raise_error
        expect(subject).to be_invalid
      end
    end

  end

  describe "short hand methods" do
    describe "question mark (?)" do
      it "should return true if value of enum equals a value" do
        expect(@obj.available?).to be_truthy
      end

      it "should return false if value of enum is different " do
        expect(@obj.canceled?).to be_falsey
      end

    end

    describe "exclemation mark (!)" do
      it "should change the value of the enum to the methods value" do
        @obj.canceled!
        expect(@obj).to be_canceled
      end

      context 'trying to set the value to the same value' do
        before { @obj.available! }
        it 'should not save the object again' do
          expect(@obj).to_not receive(:save)
          @obj.available!
        end
      end

    end

    it "should have two shorthand methods for each possible value" do
      Model::STATUSES.each do |val|
        expect(@obj.respond_to?("#{val}?")).to be_truthy
        expect(@obj.respond_to?("#{val}!")).to be_truthy
      end
    end
  end

  describe "getting value" do
    it "should always return the enums value as a symbol" do
      expect {
        @obj.status = "canceled"
      }.to change{
        @obj.status
      }.from(:available).to(:canceled)
    end

  end

  describe "setting value" do
    it "should except values as symbol" do
      @obj.status = :canceled
      expect(@obj).to be_canceled
    end

    it "should except values as string" do
      @obj.status = "canceled"
      expect(@obj).to be_canceled
    end
  end

  describe "validations" do
    let (:obj) { Model.new(:status => :available) }

    it "should not except a value outside the given list" do
      obj.status = :foobar
      expect(obj).to_not be_valid
    end

    it "should except value in the list" do
      obj.status = :canceled
      expect(obj).to be_valid
    end
  end

  describe "callbacks" do
    it "should receive a callback on change of value" do
      expect(@obj).to receive(:status_changed).with(:available,:canceled)
      @obj.canceled!
    end

    it "should not receive a callback on initial value" do
      @obj = Model.new
      expect(@obj).to_not receive(:status_changed)
      @obj.canceled!
      end

    it "should not receive a callback on value change to same" do
      expect(@obj).to_not receive(:status_changed)
      @obj.available!
    end

  end

  describe "scopes" do
    it "should return objects with given value" do
      expect(Model.available).to eq [@obj]
      expect(Model.canceled).to eq [@canceled_obj]
    end

    it "should return objects with given value when joined with models who have the same enum field" do
      expect(OtherModel.joins(:model).active).to eq [@active_obj]
    end

    describe "negation scopes" do

      it "should return objects that do not have the given value" do
        expect(Model.not_available).to include(@canceled_obj, @completed_obj)
      end

      it "should return objects that do not have the given value when joined with models who have the same enum field" do
        expect(OtherModel.joins(:model).not_active).to include(@expired_obj, @not_expired_obj)
      end

      it "should not override positive scopes" do
        # We want here to verify that the not_expired scope return only the models with
        # status == "not_expired" and not all the models with status != "expired",
        # since negation scopes should not override the "positive" scopes.
        expect(OtherModel.not_expired).to eq [@not_expired_obj]
      end

    end

  end

  it "class should have a CONST that holds all the available options of the enum" do
    expect(Model::STATUSES).to eq [:available, :canceled, :completed]
  end

  describe 'prefix' do


    context 'when prefix set to string' do

      class ModelWithPrefix < ActiveRecord::Base
        include Enumify::Model
        self.table_name = 'models'
        enum :status, [:available, :canceled, :completed], :prefix => 'foo'
      end

      subject { ModelWithPrefix.new(:status => :available) }
      it 'does not allow access through unprefixed enum' do
        expect(subject).to_not respond_to(:available?)
      end

      it 'allows access to the attributes when prefixed by that string' do
        expect(subject).to respond_to(:foo_available?)
      end

      it 'has a scope available with the prefix' do
        expect(ModelWithPrefix).to respond_to(:foo_available)
      end

      it 'has no scope for unprefixed methods' do
        expect(ModelWithPrefix).to_not respond_to(:available)
      end

      it 'has a negative scope available with the prefix' do
        expect(ModelWithPrefix).to respond_to(:not_foo_available)
      end

      it 'has no negative scope for unprefixed methods' do
        expect(ModelWithPrefix).to_not respond_to(:not_available)
      end
    end

    context 'when prefix set to true' do

      class ModelWithPrefixTrue < ActiveRecord::Base
        include Enumify::Model
        self.table_name = 'models'
        enum :status, [:available, :canceled, :completed], :prefix => true
      end

      subject { ModelWithPrefixTrue.new(:status => :available) }
      it 'does not allow access through unprefixed enum' do
        expect(subject).to_not respond_to(:available?)
      end

      it 'allows access to the attributes when prefixed by that string' do
        expect(subject).to respond_to(:status_available?)
      end

      it 'has a scope available with the prefix' do
        expect(ModelWithPrefixTrue).to respond_to(:status_available)
      end

      it 'has no scope for unprefixed methods' do
        expect(ModelWithPrefixTrue).to_not respond_to(:available)
      end

      it 'has a negative scope available with the prefix' do
        expect(ModelWithPrefixTrue).to respond_to(:not_status_available)
      end

      it 'has no negative scope for unprefixed methods' do
        expect(ModelWithPrefixTrue).to_not respond_to(:not_available)
      end
    end

  end

end
