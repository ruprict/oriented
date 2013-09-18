require 'spec_helper'

module Oriented
  describe Connection do
    after do
      Oriented.connection
    end
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
      Oriented.register_hook_class(BaseHook)
      includes_hook = false

      Oriented.connection.java_connection.hooks.each {|h| includes_hook = true if h.is_a?(BaseHook)}
      includes_hook.should be_true
    end

    it "adds only one hook to the connection" do
      Oriented.register_hook_class(BaseHook)
      Oriented.register_hook_class(OtherHook)
      Oriented.register_hook_class(BaseHook)
      counter = 0

      Oriented.connection.java_connection.hooks.each {|h| counter+= 1  if h.instance_of?(BaseHook)}
      counter.should == 1
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
