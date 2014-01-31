require 'spec_helper'

module Oriented
  module Relationships
    describe VertexInstance do
      let(:dummy_class) { define_test_class(Vertex)}
      let(:related_class) { define_test_class(Vertex)}
      let(:vertex) { v = dummy_class.new; v.save; v}
      let(:rel_type) { RelType.new("spanks", dummy_class)}
      let(:other) {o= related_class.new; o.save; o}
      subject {
        vi = described_class.new(vertex, rel_type)
        vertex.class._rels[rel_type.label.to_sym] = rel_type            
        vertex.instance_variable_get("@_relationships")[rel_type.label.to_sym] = vi        
        vi
      }

      describe ".initialize" do
        it "takes a vertex and rel_type" do
          described_class.new(vertex, rel_type)
        end
      end

      context "for a has many" do
        describe "<<" do

          it "adds a relationship" do
            # subject << other


            expect{
              subject << other
              other.save
              Oriented.graph.commit
            }.to change {subject.count}.by(1)
          end

          it "returns a vertex" do
            (subject << other).should be_a(Vertex)
          end

          context "when one exists" do
            before do
              subject << other
              other.save!
            end
            let(:other2) { o=related_class.new; o.save; o }

            it "doesn't overwrite it" do
              subject << other2
              other2.save!
              subject.to_a.count.should == 2
            end
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
        
        describe "#empty?" do
          it "returns true when no rels" do
            subject.empty?.should be_true
        
          end
        end
        
        describe "#create" do
        
          let(:dummy) {dummy_class.new} 
        
          it "creates a relationship to a new vertex of the target class" do
            dummy_class.send(:has_n, :licks).to(related_class)
            target = dummy.licks.create()
            target.should be_a(related_class) 
          end
        end

      end

      context "for a has one" do
        let(:rel_type) { RelType.new("spanks", dummy_class, {cardinality: :one})}
        
        describe "#create_relationship_to" do
          it "creates the relationship" do
            subject.create_relationship_to(other)
            other.save
            Oriented.graph.commit
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
      
      context "#destroy_all" do
        let(:rel_type) { RelType.new("spanks", dummy_class)}
        let(:other) {related_class.new}
      
        before do
          subject << other
          other.save
          Oriented.graph.commit
        end
      
         it "destroys the vertices in the relationship" do
          subject.count.should == 1 
          subject.destroy_all
          subject.count.should == 0
         end
      end
    end
  end
end
