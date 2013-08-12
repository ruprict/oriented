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


    def id
      __java_obj.id.to_s if __java_obj
    end

    # def save
    #   return unless __java_obj
    #   __java_obj.save
    #   connection.commit()  
    # end

    def persisted?
      __java_obj.id.persistent?
    end
    
     def wrapper
       self
     end       
     

    protected


    module ClassMethods 

      def new(*args)
        props = args.first
        wrapper = super()
        java_obj = Oriented::Core::JavaVertex.new("#{self.odb_class_name}")        
        wrapper.__java_obj = java_obj
        wrapper.write_default_values
        props.each_pair {|attr,val| wrapper.public_send("#{attr}=", val)} if props       
        wrapper
      end
      
      #TODO: Query methods
      def find(rid)
        vertex = Oriented.connection.graph.get_vertex(rid)
        return nil unless vertex
        m = orig_new
        m.__java_obj = vertex
        m
        #wrap(obj)
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

