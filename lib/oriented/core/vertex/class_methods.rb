module Oriented
  module Core
    module Vertex
      module ClassMethods
        # Returns a new neo4j Node.
        # The return node is actually an Java object of type Java::OrgNeo4jGraphdb::Node java object
        # which has been extended (see the included mixins for Neo4j::Node).
        #
        #
        # The created node will have a unique id - Neo4j::Property#neo_id
        #
        # @param [Hash, Array] args either an hash of properties or an array where the first item is the database to be used and the second item is the properties
        # @return [Java::OrgNeo4jGraphdb::Node] the java node which implements the Neo4j::Node mixins
        #
        # @example using default database
        #
        #  Neo4j::Transaction.run do
        #    Neo4j::Node.new
        #    Neo4j::Node.new :name => 'foo', :age => 100
        #  end
        #
        # @example using a different database
        #
        #   Neo4j::Node.new({:name => 'foo', :age => 100}, my_db)
        def new(*args)

          # the first argument can be an hash of properties to set
          props = args[0].respond_to?(:each_pair) && args[0]

          # a db instance can be given, is the first argument if that was not a hash, or otherwise the second
          # db = (!props && args[0]) || args[1] || Neo4j.started_db
          cls = (!props && args[0]) || args[1]
          
          newprop = []
          if props
            nprop = {}            
            props.keys.each do |key|
              nprop[key.to_s] = props[key]
            end
            newprop = nprop.flatten
          end
          
          vertex = Oriented.connection.graph.add_vertex("class:#{cls.to_s}", *newprop)   
          # props.each_pair { |k, v| vertex[k]= v } if props
          vertex
        end


        # create is the same as new
        alias_method :create, :new


        # Same as load but does not return the node as a wrapped Ruby object.
        
        def _load(vertex_id)
          return nil if vertex_id.nil?
          # db.graph.get_node_by_id(node_id.to_i)
            Oriented.connection.graph.get_vertex(vertex_id)
        # rescue Java::OrgNeo4jGraphdb.NotFoundException
        #   nil
        end


        # Checks if the given entity node or entity id (Neo4j::Node#neo_id) exists in the database.
        # @return [true, false] if exist
        # def exist?(entity_or_entity_id)
        #   id = entity_or_entity_id.kind_of?(String) ? entity_or_entity_id : entity_or_entity_id.id
        #   node = _load(id)
        #   return false unless node
        #   true
        # rescue java.lang.IllegalStateException
        #   nil # the node has been deleted
        # end

        # Loads a node or wrapped node given a native java node or an id.
        # If there is a Ruby wrapper for the node then it will create and return a Ruby object that will
        # wrap the java node.
        #
        # @param [nil, #to_i] node_id the neo4j node id
        # @return [Object, Neo4j::Node, nil] If the node does not exist it will return nil otherwise the loaded node or wrapped node.
        def load(vertex_id)
          vertex = _load(vertex_id)
          vertex && vertex.wrapper
        end

      end
    end
  end
end
