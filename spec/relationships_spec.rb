require 'spec_helper'


module Oriented

  describe Relationships do
    let(:model_class) { define_test_class( Vertex)}
    subject { Model.create!(name:"Barbie")}   

    describe ".has_many" do
      before(:each) do
        model_class.send(:has_n, :stylists)
      end

      it "defines a rel type based on the relation label" do
        model_class._rels[:stylists].should_not be_nil
      end

      it "defines a getter for the edges" do
        model_class.instance_methods.should include(:stylists_rels) 
      end

      it "returns an EdgesInstance for _rels" do
        model_class.new.stylists_rels.should be_a(Relationships::EdgesInstance)
      end


    end

    describe ".has_one" do
      before(:each) do
        model_class.send(:has_one, :drug_dealer)
      end

      it "defines a rel type based on the relation label" do
        model_class._rels[:drug_dealer].should_not be_nil
      end

      it "defines a getter for the relationship" do
        model_class.instance_methods.should include(:drug_dealer) 
      end

      it "defines a setter for the relationship" do
        model_class.instance_methods.should include(:drug_dealer=) 
      end

      it "defines a getter for the edge" do
        model_class.instance_methods.should include(:drug_dealer_rel) 
      end

    end
  end
end
