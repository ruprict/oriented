require 'spec_helper'

module Oriented
  module Relationships
    describe VertexInstance do
      let(:dummy_class) { define_test_class(Vertex)}
      let(:related_class) { define_test_class(Vertex)}
      let(:vertex) { v = dummy_class.new; v.save; v}
      let(:rel_type) { RelType.new("spanks", dummy_class)}
      let(:other) {o= related_class.new; o.save; o}
      subject {described_class.new(vertex, rel_type)}

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
          let(:related1) {related_class.new}
          let(:related2) {related_class.new}
          before(:each) do
            dummy_class.send(:has_n, :spanks)
            dummy.spanks << related1
            dummy.spanks << related2
            dummy.save
          end

          it "iterates through the vertices" do
            ids = [related1.id, related2.id]            
            dummy.spanks.each {|r| ids.should include(r.id)}
          end
        end

        describe "#all" do
          it "returns all the other vertices" do
            
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

          it "should take properties" do
            e = subject.create_relationship_to(other, {prop1: "val1"})
            e["prop1"].should == "val1"
          end
        end

        describe "#other_vertex" do
          it "returns the other vertex" do
            e = subject.create_relationship_to(other)
            vertex.save
            subject.other_vertex.id.to_s.should == other.id 
          end
        end
      end

    end
  end
end
