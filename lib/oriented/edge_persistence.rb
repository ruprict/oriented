module Oriented
  module EdgePersistence  
    extend ActiveSupport::Concern

    def initialize(*args)
      return initialize_attributes(nil) if args.size < 3 # then we have been loaded

      
      start_vertex, end_vertex, label, props = *args
      raise ArgumentError.new "Start vertex not supplied" unless start_vertex
      raise ArgumentError.new "Start vertex is not a vertex" unless start_vertex.is_a?(Vertex)
      raise ArgumentError.new "End vertex not supplied" unless end_vertex
      raise ArgumentError.new "End vertex is not a vertex" unless end_vertex.is_a?(Vertex)

      @label = label
      self.start_vertex = start_vertex
      self.end_vertex = end_vertex
      initialize_attributes(props)

      @_start_vertex.add_unpersisted_rel(label, self)
      @_end_vertex.add_unpersisted_rel(label, self)
      

    end

    def label
      @label
    end

    def create

      raise ArgumentError.new "Start vertex not supplied" unless start_vertex
      raise ArgumentError.new "Start vertex is not a vertex" unless start_vertex.is_a?(Vertex)
      raise ArgumentError.new "End vertex not supplied" unless end_vertex
      raise ArgumentError.new "End vertex is not a vertex" unless end_vertex.is_a?(Vertex)
            
      return unless _persist_vertex(@_start_vertex) && _persist_vertex(@_end_vertex)

      java_obj = Oriented::Core::JavaEdge.new(self.start_vertex.__java_obj, self.end_vertex.__java_obj, self.label)        
      self.__java_obj = java_obj
      self.write_all_attributes

    end

    def update
      super
      # write_changed_relationships
      # clear_relationships
      true
    end
    
    # # Reload the object from the DB
    # def reload(options = nil)
    #   # Can't reload a none persisted node
    #   return self if new_record?
    #   clear_changes
    #   clear_relationships
    #   clear_composition_cache
    #   reset_attributes
    #   unless reload_from_database
    #     set_deleted_properties
    #     freeze
    #   end
    #   self
    # end
    # 
    # def freeze_if_deleted
    #   unless new_record?
    #     Neo4j::IdentityMap.remove_node_by_id(neo_id)
    #     unless self.class.load_entity(neo_id)
    #       set_deleted_properties
    #       freeze
    #     end
    #   end
    # end
    # 
    # def reload_from_database
    #   Neo4j::IdentityMap.remove_node_by_id(neo_id)
    #   if reloaded = self.class.load_entity(neo_id)
    #     send(:attributes=, reloaded.attributes, false)
    #   end
    #   reloaded
    # end

    # Returns the start node which can be unpersisted
    # @see http://rdoc.info/github/andreasronge/neo4j-core/Neo4j/Core/Relationship#start_node-instance_method
    def start_vertex
      @_start_vertex ||= __java_obj && __java_obj.start_vertex.wrapper
    end

    # Returns the end node which can be unpersisted
    # @see http://rdoc.info/github/andreasronge/neo4j-core/Neo4j/Core/Relationship#end_node-instance_method
    def end_vertex
      @_end_vertex ||= __java_obj && __java_obj.end_vertex.wrapper
    end
    
    def other_vertex(vertex)
      n = if persisted?
            __java_obj._other_vertex(vertex.__java_obj)
          else
            @_start_vertex == vertex ? @_end_vertex : @_start_vertex
          end
      n && n.wrapper
    end
    
    
    protected

    def start_vertex=(vertex)
      old = @_start_vertex
      @_start_vertex = vertex
      # TODO should raise exception if not persisted and changed
      # if old != @_start_vertex
      #   old && old.rm_outgoing_rel(rel_type, self)
      #   @_start_vertex.class != Neo4j::Node && @_start_node.add_outgoing_rel(rel_type, self)
      # end
    end

    def end_vertex=(vertex)
      old = @_end_vertex
      @_end_vertex = vertex
      # TODO should raise exception if not persisted and changed
      # if old != @_end_node
      #   old && old.rm_incoming_rel(rel_type, self)
      #   @_end_node.class != Neo4j::Node && @_end_node.add_incoming_rel(rel_type, self)
      # end
    end
    
    def _persist_vertex(start_or_end_vertex)
      ((start_or_end_vertex.new_record? || start_or_end_vertex.relationships_changed?) && !start_or_end_vertex.create_or_updating?) ? start_or_end_vertex.save : true
    end

  end
end
