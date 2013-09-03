require 'spec_helper'

module Oriented
  describe Configuration do
    subject {described_class.new}
    describe "defaults" do
      it "defaults 'pooled' to false" do
        subject.pooled.should == false
      end
    end


    describe "block" do
      before do 
        Oriented.configure do |config|
          config.url = "remote:somehost/somedb"
          config.pooled = true
        end
      end

      after do
        Oriented.configure do |config|
          config.url = "local:#{TMP_DB_PATH}"
          config.pooled = false
        end
      end

      it "sets the config options" do
        Oriented.configuration.url.should == "remote:somehost/somedb"
        Oriented.configuration.pooled.should be_true
      end
    end
  end
end
