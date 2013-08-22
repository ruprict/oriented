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

    describe "._orient_rid" do
      it "returns the java id" do
        dummy_class.new._orient_id.should_not be_nil 
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
          dummy_class.send(:property, :kind, {type: :symbol, default: :dummy})
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

      context "restricted attributes" do

        it "includes _orient_id" do
          expect {dummy_class.send(:property, :_orient_id)}.to raise_error 
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

      it "returns instances of the class" do
        dummy_class.find(subject.id).should be_a(dummy_class) 
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
          define_edge_type("previous")
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
          define_edge_type("targets")
          subject.targets << other_class
          subject.save          
        end

        it "return previous vertex" do
          obj = dummy_class.find(subject.id)
          obj.targets.first.kind.should == "club"
        end

      end  

      describe "#find_all" do
        before(:each) do
          dummy_class.new
          dummy_class.new
          Oriented.graph.commit
        end

        it "finds all the vertices for the given class" do
          dummy_class.find_all.count == 2
        end

        it "returns instances of the class" do
          dummy_class.find_all.first.should be_a(dummy_class) 
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

    context "Persistence" do
      let(:other_class) {
        c = define_test_class(Vertex)
        c.send(:property, :kind) 
        c.new(kind: "club")
      } 
      subject {
        dummy_class.send(:property, :guid)
        dummy_class
      }

      it "should create a new java instance" do
        obj = subject.get_or_create(guid: "12345")
        obj.guid.should == "12345"

      end
    end


  end
end
