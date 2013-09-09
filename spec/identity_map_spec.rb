require 'spec_helper'

module Oriented
  describe IdentityMap do
    subject{described_class}
    let(:vertex_class) {define_test_class(Vertex) } 
    let(:edge_class) {define_test_class(Edge) } 
    let(:vertex) {vertex_class.create}
    let(:vertex2) {vertex_class.create}
    let(:edge) {edge_class.create(vertex, vertex2, "test")}

    describe ".enable" do
      it "creates the identity map" do
        described_class.enable
        described_class.enabled?.should be_true
        Thread.current[:odb_identity_map].should be_true
      end
    end

    describe ".add" do

      before do
        described_class.clear
        described_class.enable
      end

      it "adds a vertex" do
        described_class.add(vertex.__java_obj, vertex)
        described_class.get(vertex.__java_obj).should == vertex
      end

      it "adds an edge" do
        described_class.add(edge.__java_obj, edge)
        described_class.get(edge.__java_obj).should == edge
      end
    end

    describe ".clear" do
      before do
        described_class.clear
        described_class.enable
      end

      it 'removes an vertex' do
        described_class.add(vertex.__java_obj, vertex)
        described_class.get(vertex.__java_obj).should == vertex
        described_class.clear
        described_class.get(vertex.__java_obj).should be_nil
      end

    end

    describe ".remove" do
      before do
        described_class.clear
        described_class.enable
      end

      it 'removes an vertex' do
        described_class.add(vertex.__java_obj, vertex)
        described_class.get(vertex.__java_obj).should == vertex
        described_class.remove(vertex.__java_obj)
        described_class.get(vertex.__java_obj).should be_nil
      end

    end

    describe ".remove_vertex_by_id" do
      before do
        described_class.clear
        described_class.enable
      end

      it 'removes an vertex' do
        described_class.add(vertex.__java_obj, vertex)
        described_class.get(vertex.__java_obj).should == vertex
        described_class.remove_vertex_by_id(vertex.id)
        described_class.get(vertex.__java_obj).should be_nil
      end

    end

    describe ".remove_edge_by_id" do
      before do
        described_class.clear
        described_class.enable
      end

      it 'removes an edge' do
        described_class.add(edge.__java_obj, edge)
        described_class.get(edge.__java_obj).should == edge
        described_class.remove_edge_by_id(edge.id)
        described_class.get(edge.__java_obj).should be_nil
      end

    end
  end
end
