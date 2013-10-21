require 'spec_helper'

module Oriented 
  describe "Persistence" do
    let(:vertex_class) {define_test_class(Vertex)}  
    let(:vertex) {
      v = vertex_class.new
      v.save
      v
    }
    describe "destroy" do

      before do
        vertex.should be_persisted   
      end

      it "markes the object as destroyed" do
        vertex.destroy
        vertex.should be_destroyed
      end

      it "destroys the java object" do
        vertex_class.find(vertex.id.to_s).should_not be_nil
        vertex.destroy
        vertex_class.find(vertex.id.to_s).should be_nil
      end
    end

    describe "#update_attributes" do
      before do
        vertex_class.send(:property, :name)
        vertex_class.send(:property, :kind)
      end

      it "updates the attributes of the object" do
        vertex.update_attributes(name: "Fred", kind: "Yummy")  
        vertex.name.should == "Fred"
        vertex.kind.should == "Yummy"
      end

    end

    describe ".get!" do


      describe ".get!" do
        it "returns an vertex" do
          e = vertex_class.get!(vertex.id)
          e.should_not be_nil
        end
      end

    end
  end

end
