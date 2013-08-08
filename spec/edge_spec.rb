require 'spec_helper'

module Oriented
  describe Edge do
    let(:vertex_class) {define_test_class( Vertex) }
    let(:dummy_class) {define_test_class(Edge)} 

    let(:start_vertex) {vertex_class.new}
    let(:end_vertex) {vertex_class.new}
    describe ".new" do
      before(:each) do
        dummy_class.send(:property, :name) 
      end

      it "should take start and end vertices and a set of properties" do
        dc=nil
        expect{dc = dummy_class.new(start_vertex, end_vertex, name: "Fred")}.to_not raise_error
        dc.name = "Fred"
      end
    end

    describe "#start_vertex" do
      subject {
        dummy_class.new(start_vertex, end_vertex) 
      }

      it "should return the start node" do
        subject.start_vertex.id.should == start_vertex.id
      end
    end
  end
end
