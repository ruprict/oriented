require 'spec_helper'

module Oriented
  module Core
    describe JavaVertex do

      # let(:dummy_class) {Oriented::Core::Vertex} 
      subject{
        define_vertex_type("TestClass") 
        described_class.new("TestClass")
      }

      let(:other) {
        define_vertex_type("OtherClass") 
        described_class.new({name:"billy bob"}, "OtherClass")
      }

      describe ".new" do

        it "creates a java object" do
          subject.label.should == 'TestClass'
        end
      end

      context "Core::Property" do
        describe ".props" do
          it "should return orient_id with the properties" do
            other.props.keys.include?('_orient_id').should == true
          end
        end

      end

      context "rels" do
        describe "._rels" do
          before(:each) do
            subject.add_edge("previous", other)
            subject.add_edge("blah", other)            
            other.add_edge("something", subject)
          end
          it "should return the java edges" do
            subject._rels.first.element_type.should == 'Edge'
            subject._rels.count.should == 3
          end

          it "should return all outgoing java edge" do
            subject._rels(:outgoing).count.should == 2        
          end

          it "should return all outgoing java edge of type previous" do
            subject._rels(:outgoing, "previous").to_a.first.label.should == 'previous'
            subject._rels(:outgoing, "previous").count.should == 1        
          end

        end

      end

    end

  end
end
