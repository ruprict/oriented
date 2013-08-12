require 'spec_helper'

module Oriented
  describe Connection do
    context "when configured explicitly" do
      let(:dbname) { "local:#{TMP_DB_PATH}"}
      before(:each) do
        Oriented.configuration = nil
        Oriented.configure do |config|
          config.url = dbname
          config.pooled = false
        end
      end

      after(:each) do
      end

      it "creates a connection" do
        conn = Oriented.connection
        conn.graph.should_not be_nil
      end

    end
  end
end
