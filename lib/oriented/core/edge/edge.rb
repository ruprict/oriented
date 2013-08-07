module Oriented
  module Core
    # Can be used to define your own wrapper class around nodes and relationships
    module Edge

          # Same as Java::OrgNeo4jGraphdb::Relationship#getEndNode
          # @see http://api.neo4j.org/1.6.1/org/neo4j/graphdb/Relationship.html#getEndNode()
          def _end_vertex
            get_vertex(OrientDB::BLUEPRINTS::Direction::IN)
          end

          # Same as Java::OrgNeo4jGraphdb::Relationship#getStartNode
          # @see http://api.neo4j.org/1.6.1/org/neo4j/graphdb/Relationship.html#getStartNode()
          def _start_vertex
            get_vertex(OrientDB::BLUEPRINTS::Direction::OUT)
          end

          # Same as Java::OrgNeo4jGraphdb::Relationship#getNodes
          # @see http://api.neo4j.org/1.6.1/org/neo4j/graphdb/Relationship.html#getNodes()
          def _vertexes
            [_start_vertex, _end_vertex]
          end

          # Same as Java::OrgNeo4jGraphdb::Relationship#getOtherNode
          # @see http://api.neo4j.org/1.6.1/org/neo4j/graphdb/Relationship.html#getOtherNode()
          def _other_vertex(vertex)
            endv = _end_vertex
            return endv unless endv == vertex
            return _start_vertex
          end

          # Deletes the relationship between the start and end node
          # May raise an exception if delete was unsuccessful.
          #
          # @return [nil]
          def del
            delete
          end

          # Same as Java::OrgNeo4jGraphdb::Relationship#getEndNode but returns the wrapper for it (if it exist)
          # @see Neo4j::Node#wrapper
          def end_vertex
            # Just for documentation purpose, it is aliased from end_node_wrapper
          end

          # @private
          def end_vertex_wrapper
            _end_vertex.wrapper
          end

          # Same as Java::OrgNeo4jGraphdb::Relationship#getStartNode but returns the wrapper for it (if it exist)
          # @see Neo4j::Node#wrapper
          def start_vertex
            # Just for documentation purpose, it is aliased from start_node_wrapper
          end

          # @private
          def start_vertex_wrapper
            _start_vertex.wrapper
          end

          # A convenience operation that, given a node that is attached to this relationship, returns the other node.
          # For example if node is a start node, the end node will be returned, and vice versa.
          # This is a very convenient operation when you're manually traversing the node space by invoking one of the #rels
          # method on a node. For example, to get the node "at the other end" of a relationship, use the following:
          #
          # @example
          #   end_node = node.rels.first.other_node(node)
          #
          # @raise This operation will throw a runtime exception if node is neither this relationship's start node nor its end node.
          #
          # @param [Neo4j::Node] node the node that we don't want to return
          # @return [Neo4j::Node] the other node wrapper
          # @see #_other_node
          def other_vertex(vertex)
            _other_vertex(vertex._java_vertex).wrapper
          end


          # same as #_java_rel
          # Used so that we have same method for both relationship and nodes
          def _java_entity
            self
          end

          # @return self
          def _java_rel
            self
          end

          # @return [true, false] if the relationship exists
          def exist?
            Oriented::Core::Edge.exist?(self)
          end

          # Returns the relationship name
          #
          # @example
          #   a = Neo4j::Node.new
          #   a.outgoing(:friends) << Neo4j::Node.new
          #   a.rels.first.rel_type # => :friends
          # @return [Symbol] the type of the relationship
          def rel_type
            # getType().name().to_sym
            label
          end

          def class
            Oriented::Core::JavaEdge
          end


          alias_method :start_vertex, :start_vertex_wrapper
          alias_method :end_vertex, :end_vertex_wrapper


    end
  end
end
