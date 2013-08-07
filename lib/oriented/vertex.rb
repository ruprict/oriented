require 'active_support/concern'

module Oriented
  module Vertex
    extend ActiveSupport::Concern
    include Oriented::Relationships
    include Oriented::Wrapper
    include Oriented::Properties
    include Oriented::ClassName

    attr_accessor :__java_obj

    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize(attrs={})
      @__java_obj = DB.add_vertex("class:#{self.class.to_s}")        
      write_default_values
      attrs.each_pair {|attr,val| public_send("#{attr}=", val)}
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

