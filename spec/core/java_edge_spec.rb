require 'spec_helper'

module Oriented
  module Core
    describe JavaEdge do
    
      let(:obj) {Oriented::Core::JavaVertex.new('Obj1')} 
      let(:obj2) {Oriented::Core::JavaVertex.new('Obj2')}       
      
      subject{
        described_class.new(obj, obj2, "TestEdge")
      }
      
      # let(:other) {
      #   described_class.new("OtherClass")
      # }
      
      describe ".new" do
      
        it "creates a java edge object" do
          subject.label.should == 'TestEdge'
        end
      end
      
      context "Core::Edge" do
        describe '_start_vertex' do
          it 'should return the start vertex java obj' do
            subject._start_vertex.should == obj
          end
        end
        
        describe '_end_vertex' do
          it 'should return the end vertex java obj' do
            subject._end_vertex.should == obj2
          end
        end  
        
        describe '_other_vertex' do
          it 'should return the end vertex java obj' do
            subject._other_vertex(obj).should == obj2
          end
        end              
        
      end
      # context "rels" do
      #   describe "._rels" do
      #     before(:each) do
      #       subject.add_edge("previous", other)
      #       subject.add_edge("blah", other)            
      #       other.add_edge("something", subject)
      #     end
      #     it "should return the java edges" do
      #       subject._rels.first.element_type.should == 'Edge'
      #       subject._rels.count.should == 3
      #     end
      #   
      #     it "should return all outgoing java edge" do
      #       subject._rels(:outgoing).count.should == 2        
      #     end
      #     
      #     it "should return all outgoing java edge of type previous" do
      #       subject._rels(:outgoing, "previous").to_a.first.label.should == 'previous'
      #       subject._rels(:outgoing, "previous").count.should == 1        
      #     end
      #     
      #   end
      #   
      # end
      
    end
    
  end
end