module Oriented
  module ClassName
    extend ActiveSupport::Concern
    
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def set_odb_class_name(val)
        @_obd_class_name = val
      end

      def odb_class_name
        @_obd_class_name ||= name.to_s
      end
      
      def oclass
        Oriented.connection.graph.get_vertex_type(odb_class_name) 
      end
    end
  end
end
