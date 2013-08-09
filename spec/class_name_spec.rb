require 'spec_helper'

module Oriented
  describe ClassName do
    let(:dummy_class) {define_test_class(ClassName)} 

    it "defines a setter method" do
      dummy_class.set_odb_class_name "ODBClass"
    end

    it "defines a getter method" do
      dummy_class.set_odb_class_name "ODBClass"
      dummy_class.odb_class_name.should == "ODBClass"
    end

    it "is the same as the Ruby class name" do
      dummy_class.odb_class_name.should == dummy_class.name 
    end
  end


end
