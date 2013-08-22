require 'spec_helper'

module Oriented
  describe Connection do
    context "when configured explicitly" do

      it "creates a connection" do
        conn = Oriented.connection
        conn.graph.should_not be_nil
      end
    end

    context "when it's closed" do

      it "gets a new connection" do
        Oriented.connection.close 
        Oriented.connection.java_connection.closed?.should be_false
      end
    end
  end
end
