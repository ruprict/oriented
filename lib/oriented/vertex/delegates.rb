module Oriented
  module Vertex
    module Delegates
      extend Forwardable
      extend ActiveSupport::Concern      

      # def_delegator :__java_obj, :setProperty, :[]=
      # def_delegator :__java_obj, :getProperty, :[]
      # def_delegator :__java_obj, :get_rid, :id
      # def_delegator :__java_obj, :get_rid, :_orient_id
      def_delegator :__java_obj, :_rels, :_rels      
      
      class << self
        private
        # @macro  [new] node.delegate
        #   @method $1(*args, &block)
        #   Delegates to {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/$2#$1-instance_method Neo4j::Core::Node#$1} using the <tt>_java_entity</tt> instance with the supplied parameters.
        #   @see Neo4j::NodeMixin#_java_entity
        #   @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/$2#$1-instance_method Neo4j::Core::Node#$1
        def delegate(*args)
          method_name = args.slice(0)
          java_method_name = args.pop          
          class_eval(<<-EOM, __FILE__, __LINE__)
            def #{method_name}(*args, &block)
              return nil if !__java_obj
              __java_obj.send(:#{java_method_name}, *args, &block)
            end
          EOM
        end
      end
      
      # @macro  node.delegate
      delegate :[]=

      # @macro  node.delegate
      delegate :[], 'getProperty'
      
      delegate :id, 'get_rid'   

      delegate :_orient_id, 'get_rid'
      
    end
  end
end
