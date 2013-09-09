module Oriented
  module VertexPersistence  
    extend ActiveSupport::Concern

    def initialize(attributes = nil)
      initialize_relationships
      initialize_attributes(attributes)
    end


    def create
      mergeprops = self.class.attribute_defaults.merge(self.props||{})      

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


  end
end
