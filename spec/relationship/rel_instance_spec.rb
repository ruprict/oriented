require 'spec_helper'

module Oriented
  module Relationship
    describe RelInstance do
      let(:dummy_class) { Class.new.send(:include, Vertex)}
      let(:related_class) { Class.new.send(:include, Vertex)}
      let(:vertex) { v = dummy_class.new; v.save; v}
      let(:rel_type) { RelType.new("spanks", dummy_class)}
      let(:other) {o= related_class.new; o.save; o}
      subject {described_class.new(vertex, rel_type)}

      before(:each) do
        Object.const_set("Class#{rand(100)}", related_class)
      end

      describe ".initialize" do
        it "takes a vertex and rel_type" do
          described_class.new(vertex, rel_type)
        end
      end

      context "for a has many" do
        describe "<<" do

          it "adds a relationship" do
            expect{subject << other}.to change {subject.count}.by(1)
          end
        end

        describe "#each" do 
          let(:dummy) {dummy_class.new}
          let(:related) {related_class.new}
          before(:each) do
            dummy.spanks << related 
          end
        end
      end

      context "for a has one" do
        let(:rel_type) { RelType.new("spanks", dummy_class, {cardinality: :one})}

        describe "#create_relationship_to" do
          it "creates the relationship" do
            subject.create_relationship_to(other)
            subject.map(&:id).should include(other.id)
          end
        end

        describe "#other_node" do
          it "returns the other node" do
            e = subject.create_relationship_to(other)
            vertex.save
            puts e.identity.to_s
            subject.other_node.id.to_s.should == other.id 
          end
        end

      end

    end
  end
end
