module Oriented
  module Vertex
    module Delegates
      extend Forwardable
      # def_delegator :__java_obj, :id, 
      # @macro  node.delegate
      def_delegator :__java_obj, :[]=, 'setProperty'

      # @macro  node.delegate
      def_delegator :__java_obj, :[], 'getProperty'
    end
  end
end
