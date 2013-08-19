module Oriented
  module TypeConverters
    describe ".convert" do
       it "returns a default converter" do
        Oriented::TypeConverters.convert("test").should == "test" 
       end

       it "converts a symbol" do
         Oriented::TypeConverters.convert(:test).should == "test" 
       end

       it "converts a Fixnum" do
         Oriented::TypeConverters.convert(101).should == 101
       end

       it "converts a DateTime" do
         dt = DateTime.new(2013, 12, 30)
         Oriented::TypeConverters.convert(dt).should == dt.to_time.to_i
       end

       it "converts a Set" do
         set = Set.new([1,2,3])
         Oriented::TypeConverters.convert(set).should == Set.new([ 1,2,3 ]).to_java
       end
    end
  end
end
