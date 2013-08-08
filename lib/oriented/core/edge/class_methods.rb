module Oriented
  module Core
    module Edge
      module ClassMethods

        # Returns a Java::OrgNeo4jGraphdb::Relationship java object which include the Neo4j::Relationship mixins.
        # Will trigger a event that the relationship was created.
        #
        # @param [String, Symbol] type of relationship
        # @param [#_java_node] from_node the start node of this relationship
        # @param [#_java_node] end_node the end node of this relationship
        # @param [Hash] props optional properties for the created relationship
        #
        # @return [Neo4j::Relationship] which is really a Java::OrgNeo4jGraphdb::Relationship java object including the Neo4j::Relationship mixins
        #
        # @example
        #
        #  Neo4j::Relationship.new :friend, node1, node2, :since => '2001-01-02', :status => 'okey'
        #
        def new(start_vertex, end_vertex, type, props=nil)
          # java_type = ToJava.type_to_java(type)
          # rel = start_vertex._java_obj.create_relationship_to(end_vertex._java_obj, java_type)
          rel = start_vertex.add_edge(type, end_vertex)            
          props.each_pair { |k, v| rel[k] = v } if props
          rel
        end
        

        # create is the same as new
        alias_method :create, :new

        # Loads a relationship or wrapped relationship given a native java relationship or an id.
        # If there is a Ruby wrapper for the node then it will create a Ruby object that will
        # wrap the java node (see Neo4j::RelationshipMixin).
        # Notice that it can load the node even if it has been deleted in the same transaction, see #exist?
        #
        # @see #_load
        # @see #exist?
        # @return the wrapper for the relationship or nil
        def load(edge_id)
          # edge = _load(edge_id)
          # return nil if edge.nil?
          # edge && edge.wrapper
        end

        # Same as load but does not return the node as a wrapped Ruby object.
        # @see #load
        def _load(edge_id)
          # return nil if edge_id.nil?
          # DB.get_edge(edge_id)
        # rescue Java::OrgNeo4jGraphdb::NotFoundException
        #   nil
        end

        # Checks if the given node or entity id (Neo4j::Relationship#neo_id) exists in the database.
        # @return [true, false] if exist
        def exist?(entity_or_entity_id)
          # id = entity_or_entity_id.kind_of?(String) ? entity_or_entity_id : entity_or_entity_id.id
          # entity = _load(id)
          # return false unless entity
          # entity.hasProperty('_classname') # since we want a IllegalStateException which is otherwise not triggered
          # true
        # rescue java.lang.IllegalStateException
          # nil # the node has been deleted
        end

      end
    end
  end
end
