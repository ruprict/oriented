module Oriented
  module VertexMethods
    extend ActiveSupport::Concern    

    module ClassMethods 
      
      class << self
        include Oriented::Core::TransactionWrapper
      end

      def new(*args, &block)
        props = args.first
        wrapper = super()
    
        nprop = {}   
        if props         
          props.keys.each do |key|
            nprop[key.to_s] = self._converter(key).to_java(props[key]) if props[key]
          end
        end
    
        mergeprops = wrapper.class.attribute_defaults.merge(nprop||{})
        Rails.logger.info("merge props = #{mergeprops}")
        puts "merge props = #{mergeprops}"
                  
        java_obj = Oriented::Core::JavaVertex.new(mergeprops, "#{Oriented::Registry.odb_class_for(self.name.to_s)}")        
        wrapper.__java_obj = java_obj
        # wrapper.write_default_values
        # props.each_pair {|attr,val| wrapper.public_send("#{attr}=", val)} if props       
        wrapper
      end
      
        alias_method :create, :new      
  
      #TODO: Query methods
      def find(rid)
        vertex = Oriented.graph.get_vertex(rid)
        return nil unless vertex
        vertex.wrapper
      end
      wrap_in_transaction :find

      def find_all
        Oriented.graph.get_vertices_of_class(Oriented::Registry.odb_class_for(self.name.to_s), false).map(&:wrapper)
      end
      wrap_in_transaction :find_all
  
      def load_entity(rid)
          vertex = Oriented::Core::JavaVertex._load(rid)
          return nil if vertex.nil?
          return vertex if vertex.class == Oriented::Core::JavaVertex
          vertex.kind_of?(self) ? vertex : nil
      end
  
      def to_adapter 
        self
      end
  

      protected

      def field_names
        @field_names ||= []
      end
    end
  end
end