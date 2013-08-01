require 'spec_helper'

module Oriented
  module Relationship
    describe RelType do
      let(:dummy_class) {Class.new.send(:include, Vertex)}
      
      describe ".initialize" do
        it "takes a label, source_class, and options" do
           expect{described_class.new("touches", dummy_class, {})}.to_not raise_error
        end
      end

      describe "#direction" do
        subject{described_class.new("touches", dummy_class, {dir: Oriented::Relationships::Direction::BOTH})}

        it "is an option" do
          subject.direction.should == Oriented::Relationships::Direction::BOTH
        end

        it "defaults to OUT" do
          described_class.new("touches", dummy_class).direction.should == Oriented::Relationships::Direction::OUT
        end
      end

      describe "#cardinality" do
        it "is an option" do
          described_class.new("touches", dummy_class, {cardinality: :one }).cardinality.should == :one
        end

        it "defaults to many" do
          described_class.new("touches", dummy_class).cardinality.should == :many
        end
      end

    end
  end
end
