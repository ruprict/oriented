require 'spec_helper'

module Oriented
  module Relationship
    describe RelType do
      let(:dummy_class) {define_test_class( Vertex)}

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

      describe "#from" do
        let(:other_class) {
          define_test_class( Vertex)
        }
        context "when just a symbol is passed " do

          subject{described_class.new("touches", dummy_class).from(:target)}

          it "sets the direction to in" do
            subject.direction.should == Oriented::Relationships::Direction::IN
          end

          it "makes the label the symbol" do
            subject.label.should == :target.to_s
          end

        end

        context "when a class name and a symbol are passed" do
          before(:each){ dummy_class.set_odb_class_name "TestODB"}
          subject{described_class.new("touches", dummy_class).from(other_class, :target)}

          it "makes the direction in" do
            subject.direction.should == Oriented::Relationships::Direction::IN
          end

          it "makes the label the symbol plus target class" do
            subject.label.should == "#{dummy_class.odb_class_name}-target"
          end

          it "sets the target class" do
            subject.target_class.should == other_class.to_s
          end
        end
      end

      describe "#to" do
        let(:other_class) {Class.new.send(:include, Vertex)}
        context "when just a symbol is passed " do

          subject{described_class.new("touches", dummy_class).to(:target)}

          it "sets the direction to out" do
            subject.direction.should == Oriented::Relationships::Direction::OUT
          end

          it "makes the label the symbol" do
            subject.label.should == :target.to_s
          end

        end

        context "when a class name is passed" do
          before(:each){ dummy_class.set_odb_class_name "TestODB"}
          subject{described_class.new("touches", dummy_class).to(other_class)}

          it "makes the direction out" do
            subject.direction.should == Oriented::Relationships::Direction::OUT
          end

          it "makes the label the source class name method target class name" do
            subject.label.should == "#{dummy_class.odb_class_name}-touches" 
          end

          it "sets the target class" do
            subject.target_class.should == other_class.odb_class_name
          end
        end
      end
    end
  end
end
