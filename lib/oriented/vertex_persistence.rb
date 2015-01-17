module Oriented
  module VertexPersistence  
    extend ActiveSupport::Concern

    def initialize(attributes = nil)
      initialize_relationships
      initialize_attributes(attributes)
    end


    def create
      mergerubyprops = self.class.attribute_defaults.merge(self.props||{})
      mergeprops = mergerubyprops.keys.inject({}){ |r, k| r[k] = self.class._converter(k.to_sym).to_java(mergerubyprops[k]); r }
      java_obj = Oriented::Core::JavaVertex.new(mergeprops, "#{Oriented::Registry.odb_class_for(self.class.name.to_s)}")
      self.__java_obj = java_obj
      self.write_changed_relationships
      # self.clear_relationships
      true
      # # wrapper.write_default_values
      # # props.each_pair {|attr,val| wrapper.public_send("#{attr}=", val)} if props       
      # wrapper
    end

    def update
      super
      write_changed_relationships
      # clear_relationships
      true
    end
    
    def reload
      # Can't reload a none persisted node
      return self if new_record?
      clear_relationships
      reset_attributes      
      self.__java_obj.record.reload    
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
    def freeze_if_deleted
      unless new_record?
        # Neo4j::IdentityMap.remove_node_by_id(neo_id)
        # unless self.class.load_entity(neo_id)
        #   set_deleted_properties
        #   freeze
        # end
      end
    end
    
    def reload_from_database
      # Neo4j::IdentityMap.remove_node_by_id(neo_id)
      if reloaded = self.class.get!(rid)
        # puts "THE RELOADED PROPS = #{reloaded.props}"
        send(:attributes=, reloaded.props, false)
      end
      reloaded
    end

    module ClassMethods
      def get!(rid)          
        if rid.kind_of?(Hash)
          if rid.count > 1

          else
            clname = Oriented::Registry.odb_class_for(self.name.to_s)
            rr = rid.flatten
            key = clname+"."+rr[0].to_s.split(".").last
            val = rr[1].to_s
            vertex = Oriented.graph.get_vertices(key, val).first
            vertex = nil if !vertex || (vertex.label != clname && !vertex.record.getSchemaClass().sub_class_of?(clname))
            
          end

        else
          vertex = Oriented.graph.get_vertex(rid)            
        end

        return nil unless vertex
        vertex.wrapper
        # m = orig_new
        # m.__java_obj = vertex
        # m
      end
    end

  end
end
