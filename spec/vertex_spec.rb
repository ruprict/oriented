require 'spec_helper'

module Oriented
  describe Vertex do

    let(:dummy_class) {define_test_class(Vertex)} 
    subject{
      dummy_class.send(:property, :name) 
      dummy_class.new
    }
    describe ".new" do
      
      it "creates a java object" do
        subject.__java_obj.should_not be_nil
      end

      it "takes a list of attributes" do
        dummy_class.send(:property, :name)
        dummy_class.new(name: 'Bob').name.should == 'Bob' 
      end
    end

    describe ".property" do
      before(:each) do
        subject.name = "Fred"
      end

      it "defines getter on model" do
        subject.name.should == "Fred"
      end

      context "taking a default value" do
        before(:each) do
          dummy_class.send(:property, :kind, {default: :dummy})
        end

        it "works" do
          dummy_class.new.kind.should == :dummy
        end

        it "doesn't override passed in attributes" do
          dummy_class.new(kind: :smarty).kind.should == :smarty
        end
      end

      context "specifying a type" do
        before(:each) do
          dummy_class.send(:property, :kind, {default: :dummy, type: :symbol})
        end

        it "works" do
          dummy_class._props[:kind][:converter].should == Oriented::TypeConverters::SymbolConverter
        end
        
      end
    end

    describe ".odb_class_name" do

      it "is the same as the Ruby class name" do
        dummy_class.odb_class_name.should == dummy_class.name 
      end

      context "when specified" do
        it "sets the odb_class_name" do
          dummy_class.send(:odb_class_name=, "Buckets")
          dummy_class.odb_class_name.should == "Buckets" 
        end
      end
    end

    describe "#save" do
      it "persists the object" do
        subject.name = 'Fred'
        subject.save
        subject.persisted?.should be_true
      end
    end
    
    describe "#find" do
      it "returns a wrapped vertex" do
        subject.save
        obj = dummy_class.find(subject.id)
        obj.__java_obj.should == subject.__java_obj
      end

      context "has_one" do
        
        let(:other_class) {
          c = define_test_class(Vertex)
          c.send(:property, :kind) 
          c.new(kind: "club")
        } 
        subject {
          dummy_class.send(:has_one, :previous)
          dummy_class.new
        }
        before(:each) do
          subject.previous = other_class
          subject.save          
        end
        
        it "return previous vertex" do
          obj = dummy_class.find(subject.id)
          obj.previous.kind.should == "club"
        end
        
      end    
      
      context "has_many" do
        
        let(:other_class) {
          c = define_test_class(Vertex)
          c.send(:property, :kind) 
          c.new(kind: "club")
        } 
        subject {
          dummy_class.send(:has_n, :targets)
          dummy_class.new
        }
        before(:each) do
          subject.targets << other_class
          subject.save          
        end
        
        it "return previous vertex" do
          obj = dummy_class.find(subject.id)
          obj.targets.first.kind.should == "club"
        end
        
      end  
      
      context "props" do
        let(:other_class) {
          c = define_test_class(Vertex)
          c.send(:property, :kind) 
          obj = c.new(kind: "club")
          obj["testprop"] = "test"
          obj.save
          obj
        }
        
        it "return all props" do          
          other_class.props.should == {"kind"=>"club", "testprop"=>"test"}
        end
        
      end
    end
    
  end
end
