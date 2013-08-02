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
    end
  end
end
