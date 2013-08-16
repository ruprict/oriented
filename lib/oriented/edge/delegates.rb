module Oriented
  module Edge
    module Delegates
      extend Forwardable
      def_delegators :__java_obj, :start_vertex, :end_vertex, :label
      def_delegator :__java_obj, :get_rid, :id
      def_delegator :__java_obj, :get_rid, :_orient_id
    end
  end
end
