require 'spec_helper'

module Oriented
  module Relationships
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

        context "when a string is passed in" do
          it "makes it a direction" do
          described_class.new("touches", dummy_class, {dir: "out"}).direction.should == Oriented::Relationships::Direction::OUT
          end
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
          before(:each){ Oriented::Registry.stub(:odb_class_for) {"TestODB"}}
          subject{described_class.new("touches", dummy_class).from(other_class, :target)}

          it "makes the direction in" do
            subject.direction.should == Oriented::Relationships::Direction::IN
          end

          it "makes the label the symbol plus target class" do
            subject.label.should == "#{other_class.odb_class_name}__target"
          end

          it "sets the target class" do
            subject.target_class.to_s.should == other_class.odb_class_name.to_s
          end
        end
      end

      describe "#to" do
        let(:other_class) {define_test_class( Vertex)}
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
          subject{described_class.new("touches", dummy_class).to(other_class)}

          it "makes the direction out" do
            subject.direction.should == Oriented::Relationships::Direction::OUT
          end

          it "makes the label the source class name method target class name" do
            subject.label.should == "#{dummy_class.odb_class_name}__touches" 
          end

          it "sets the target class" do
            subject.target_class.to_s.should == other_class.odb_class_name
          end
        end
      end
      
      describe "#relationship and relationship_class" do
        let(:rel_class) {define_test_class(Edge)} 
        subject{described_class.new("touches", dummy_class)}
        it "takes a class" do
          subject.relationship(rel_class) 
        end

        it "returns that class" do
          subject.relationship(rel_class) 
          subject.relationship_class.should == rel_class
        end
      end
    end
  end
end
