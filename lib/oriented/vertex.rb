require 'active_support/concern'

module Oriented
  module Vertex
    extend ActiveSupport::Concern
    include Oriented::Vertex::Delegates    

    include Oriented::ClassName    
    include Oriented::Persistence
    include Oriented::Relationships
    # extend Oriented::Wrapper::ClassMethods
        
    include Oriented::Wrapper
    include Oriented::Properties


    def self.included(base)
      base.extend(ClassMethods)
      base.extend Oriented::Wrapper::ClassMethods      
    end

    def persisted?
      __java_obj.id.persistent?
    end
    
     def wrapper
       self
     end       
     

    protected


    module ClassMethods 

      class << self
        include Oriented::Core::TransactionWrapper
      end

      def new(*args)
        props = args.first
        wrapper = super()
        java_obj = Oriented::Core::JavaVertex.new("#{Oriented::Registry.odb_class_for(self.name.to_s)}")        
        wrapper.__java_obj = java_obj
        wrapper.write_default_values
        props.each_pair {|attr,val| wrapper.public_send("#{attr}=", val)} if props       
        wrapper
      end
      
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

