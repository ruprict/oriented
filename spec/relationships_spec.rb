require 'spec_helper'


module Oriented

  describe Relationships do
    let(:model_class) { Class.new.send(:include, Vertex)}
    subject { Model.create!(name:"Barbie")}   

    describe ".has_many" do
      before(:each) do
        model_class.send(:has_n, :stylists)
      end

      it "defines a rel type based on the relation label" do
        model_class._rels[:stylists].should_not be_nil
      end

      describe ".build" do

        
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
    end
  end
end
