module Oriented
  module Edge
    module Delegates
      extend Forwardable
      def_delegator :__java_obj, :start_vertex
    end
  end
end
