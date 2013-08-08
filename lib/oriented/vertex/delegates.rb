module Oriented
  module Vertex
    module Delegates
      extend Forwardable
      # def_delegator :__java_obj, :id, 

      def_delegator :__java_obj, :setProperty, :[]=
      def_delegator :__java_obj, :getProperty, :[]
    end
  end
end
