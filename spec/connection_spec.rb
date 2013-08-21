require 'spec_helper'

module Oriented
  describe Connection do
    context "when configured explicitly" do

      it "creates a connection" do
        conn = Oriented.connection
        conn.graph.should_not be_nil
      end

    end
  end
end
