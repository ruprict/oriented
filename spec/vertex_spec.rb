require 'spec_helper'

module Oriented
  describe Vertex do

    let(:dummy_class) {Class.new.send(:include, Vertex)} 
    subject{Model.new}
    describe "#new" do
      
      it "creates a java object" do
        subject.__java_obj.should_not be_nil
      end

      it "takes a list of attributes" do
        dummy_class.send(:property, :name)
        dummy_class.new(name: 'Bob').name.should == 'Bob' 
      end
    end

    describe ".property" do
      before(:each) do
        subject.name = "Fred"
      end

      it "defines getter on model" do
        subject.name.should == "Fred"
      end
    end

    describe ".save" do
      it "persists the object" do
        subject.name = 'Fred'
        subject.save
        subject.persisted?.should be_true
      end
    end
  end
end
