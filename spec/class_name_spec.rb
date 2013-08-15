require 'spec_helper'

module Oriented
  describe ClassName do
    let(:dummy_class) {define_test_class(ClassName)} 
   
    it "is the same as the Ruby class name" do
      dummy_class.odb_class_name.should == dummy_class.name 
    end

    context "when mapped" do
      before(:each) do
        Oriented::Registry.stub(:odb_class_for).with(dummy_class.name) { "ODBClass"}
      end

      it "returns the mapped class" do
        dummy_class.odb_class_name.should == "ODBClass"
      end

    end

  end


end
