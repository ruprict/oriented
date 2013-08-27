module Oriented
  module Vertex
    module Delegates
      extend Forwardable

      def_delegator :__java_obj, :setProperty, :[]=
      def_delegator :__java_obj, :getProperty, :[]
      def_delegator :__java_obj, :get_rid, :id
      def_delegator :__java_obj, :get_rid, :_orient_id
      def_delegator :__java_obj, :_rels, :_rels      
    end
  end
end
