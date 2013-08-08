require 'active_support/concern'

module Oriented
  module Vertex
    extend ActiveSupport::Concern

    include Oriented::Relationships
    # extend Oriented::Wrapper::ClassMethods
        
    # include Oriented::Wrapper
    include Oriented::Properties
    include Oriented::ClassName


    
    attr_accessor :__java_obj

    def self.included(base)
      base.extend(ClassMethods)
      base.extend Oriented::Wrapper::ClassMethods      
    end


    def __java_obj
      @__java_obj 
    end

    def id
      __java_obj.id.to_s if __java_obj
    end

    def save
      return unless __java_obj
      __java_obj.save
      connection.commit()  
    end

    def persisted?
      __java_obj.id.persistent?
    end

    protected

    def connection
      __java_obj.graph || self.class.connection
    end

    module ClassMethods 

      def new(*args)
        props = args.first
        wrapper = super()
        java_obj = Oriented::Core::JavaVertex.new("#{wrapper.class.to_s}")        
        wrapper.__java_obj = java_obj
        wrapper.write_default_values
        props.each_pair {|attr,val| wrapper.public_send("#{attr}=", val)} if props       
        wrapper
        # write_default_values
        # attrs.each_pair {|attr,val| public_send("#{attr}=", val)}
      end
      
      #TODO: Query methods
      def find(rid)
        connection.get_vertex(rid)
        #wrap(obj)
      end

      #TODO: Need to handle connections properly
      def connection
        DB 
      end

      protected

      def field_names
        @field_names ||= []
      end
    end
  end
end

