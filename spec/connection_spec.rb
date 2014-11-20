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
  end

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

  end
end
