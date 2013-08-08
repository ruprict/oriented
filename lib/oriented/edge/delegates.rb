module Oriented
  module Edge
    module Delegates
      extend Forwardable
      def_delegators :__java_obj, :start_vertex, :end_vertex, :label
    end
  end
end
