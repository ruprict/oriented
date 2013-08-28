require 'spec_helper'

module Oriented
  describe Edge do
    let(:vertex_class) {define_test_class( Vertex) }
    let(:dummy_class) {define_test_class(Edge)} 

    let(:start_vertex) {vertex_class.new}
    let(:end_vertex) {vertex_class.new}
    describe ".new" do
      before(:each) do
        define_edge_type("knows")
        dummy_class.send(:property, :name) 
      end

      it "should take start and end vertices, a label,  and a set of properties" do
        dc=nil
        expect{dc = dummy_class.new(start_vertex, end_vertex, "knows", name: "Fred")}.to_not raise_error
        dc.name = "Fred"
        dc.label.should == "knows"
      end

      it "raises an error if args not supplied" do
        expect{dc = dummy_class.new}.to raise_error ArgumentError
      end

      it "raises an error if first arg is not a Vertex" do
        expect{dc = dummy_class.new(Object.new, vertex_class.new)}.to raise_error ArgumentError
      end

      it "raises an error if second arg is not supplied" do
        expect{dc = dummy_class.new(Object.new)}.to raise_error ArgumentError
      end

      it "raises an error if second arg is not a Vertex" do
        expect{dc = dummy_class.new(dummy_class.new, Object.new)}.to raise_error ArgumentError
      end
    end

    describe "#start_vertex" do
      subject {
        dummy_class.new(start_vertex, end_vertex, "knows") 
      }

      it "should return the start vertex" do
        subject.start_vertex.id.should == start_vertex.id
      end
    end

    describe "#end_vertex" do
      subject {
        dummy_class.new(start_vertex, end_vertex, "knows") 
      }

      it "should return the end vertex" do
        subject.end_vertex.id.should == end_vertex.id
      end
    end

    describe "#find" do
      subject {
        dummy_class.new(start_vertex, end_vertex, "knows") 
      }
      context "without properties" do
        it "returns a edge" do
          subject.save
          Oriented.graph.commit
          obj = dummy_class.find(subject.id)
          obj.class.should.to_s === Oriented::Core::JavaEdge.to_s

        end
      end

      context "with properties" do
        subject {
          dummy_class.send(:property, :prop)
          dummy_class.new(start_vertex, end_vertex, "knows", {prop: "val"}) 
        }

        before(:each) do
          Oriented::Registry.stub(:ruby_class_for).with("knows").and_return(dummy_class.name)
        end
        
        it "returns instance of the class" do
          dummy_class.find(subject.id).should be_a(dummy_class) 
        end
      end
    end
  end
end
