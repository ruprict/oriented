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
         Oriented::TypeConverters.convert(dt).should == dt.to_time
       end

       it "converts a Date" do
         dt = Date.new(2013, 12, 30)
         Oriented::TypeConverters.convert(dt).should == dt
       end

       it "converts a Set" do
         set = Set.new([1,2,3])
         Oriented::TypeConverters.convert(set).should == Set.new([ 1,2,3 ]).to_java
       end
    end


    describe DateTimeConverter do
      describe ".to_ruby" do
        it "converts java to ruby" do
          exp_dt = DateTime.new(2013, 12, 30)
          dt = Java::JavaUtil::Date.new(exp_dt.to_time.to_i * 1000)
          DateTimeConverter.to_ruby(dt).should == exp_dt
        end
      end
    end

    describe DateConverter do
      describe ".to_ruby" do
        it "converts java to ruby" do
          exp_dt = Date.new(2013, 12, 30)
          dt = Java::JavaUtil::Date.new(exp_dt.to_time.to_i * 1000)
          DateConverter.to_ruby(dt).should == exp_dt
        end
      end
    end

    describe TimeConverter do
      describe ".to_ruby" do
        it "converts java to ruby" do
          exp_dt = Time.new(2013, 12, 30)
          dt = Java::JavaUtil::Date.new(exp_dt.to_time.to_i * 1000)
          TimeConverter.to_ruby(dt).should == exp_dt
        end
      end
    end
  end
end
