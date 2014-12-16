require_relative "./fixtures/models"
require 'spec_helper'

module Oriented
  describe Connection do
    context "when configured explicitly" do

      it "creates a connection" do
        conn = Oriented.connection
        conn.graph.should_not be_nil
      end
    end

    context "when it's closed" do
      it "gets a new connection" do
        Oriented.connection.close
        Oriented.connection.java_connection.closed?.should be_false
      end
    end

    context "opening and reconnectiong" do
      it "works" do
        100.times do 
          Oriented.connection 
          Oriented.connection.close
          Oriented.connection 
          Oriented.connection.close
          Oriented.connection 
          Oriented.connection.close
          Oriented.connection
          Oriented.connection.close
          Oriented.connection
        end
      end
    end

    context "when committing" do
      let(:barbie) { Model.new(name: "Barbie")}
      let(:barbie2) { Model.new(name: "Barbie2")}

      before do
        Oriented::IdentityMap.enable
        %w(Model DrugDealer Stylist).each do |vt|
          Oriented.graph(true).create_vertex_type(vt) unless Oriented.connection.graph.get_vertex_type(vt)
        end
        barbie2.save
      end

      context "on success " do
        it "should clear out the IdentityMap" do
          expect { Oriented.connection.commit  }.to change {
            Oriented::IdentityMap.all.count
          }.by(-1)
        end
      end

      context "on failure " do
        before do
          barbie2.save!
          Oriented.connection.stub_chain("java_connection.closed?").and_return(false)
        end

        after do
          Oriented.connection.max_retries = 1
        end

        it "should rollback the graph" do
          Oriented.connection.graph.stub(:commit) { raise Error }
          Oriented.connection.should_receive(:rollback)
          begin
            Oriented.connection.commit  do
              raise StandardError
            end
          rescue
            nil
          end
        end

        it "should raise ConcurrentModificationError" do
          t1 = Thread.new do |t|
            Oriented::IdentityMap.enable
            graph = ConnectionFactory.instance.connection
            bb = graph.get_vertex(barbie2.id.to_s).wrapper
            bb.name = "barbie_changed"
            bb.save
            graph.commit
          end
          t1.join()
          barbie2.name = "barb"
          barbie2.save

          Oriented.connection.max_retries = 0
          expect { Oriented.connection.commit }.to raise_error(Java::ComOrientechnologiesOrientCoreException::OConcurrentModificationException)
        end

        it "should save property again after ConcurrentModificationError" do
          t1 = Thread.new do |t|
            Oriented::IdentityMap.enable
            graph = ConnectionFactory.instance.connection
            bb = graph.get_vertex(barbie2.id.to_s).wrapper
            bb.name = "barbie_changed"
            bb.save
            graph.commit
          end
          t1.join()
          barbie2.name = "barb"
          barbie2.save

          Oriented.connection.should_receive(:increment_retry).once
          Oriented.connection.commit
          Oriented.graph.get_vertex(barbie2.id.to_s).wrapper.name.should == "barb"
        end

      end # END ON FAILURE
    end # End on Committing

    describe "Hooks" do

      class OtherHook < BaseHook
      end

      after do
        [BaseHook, OtherHook].each {|h| Oriented.unregister_hook_class(h)}
        Oriented.hook_classes.clear
      end

      it "can be added" do
        Oriented.register_hook_class(BaseHook)
        Oriented.hook_classes.to_a.should == [BaseHook]
      end

      it "adds hooks to the connection" do
        puts Oriented.connection.java_connection.hooks.count
        expect { Oriented.register_hook_class(BaseHook) }.to change {
          Oriented.connection.java_connection.hooks.count
        }.by(1)
      end

      it "adds only one hook to the connection" do
        expect {
          Oriented.register_hook_class(BaseHook)
          Oriented.register_hook_class(OtherHook)
          Oriented.register_hook_class(BaseHook)
           }.to change {
          Oriented.connection.java_connection.hooks.count
        }.by(2)
      end

      it "removes the hook" do
        Oriented.register_hook_class(BaseHook)
        Oriented.register_hook_class(OtherHook)
        Oriented.unregister_hook_class(BaseHook)
        Oriented.hook_classes.to_a.should == [OtherHook]

        includes_hook = false
        Oriented.connection.java_connection.hooks.each {|h| includes_hook = true if h.instance_of?(BaseHook)}
        includes_hook.should be_false
      end
    end # End HOOKS
  end
end
