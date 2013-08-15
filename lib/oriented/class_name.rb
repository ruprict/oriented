module Oriented
  module ClassName
    extend ActiveSupport::Concern
    
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def odb_class_name
        Oriented::Registry.odb_class_for(self.name.to_s)
      end
      
      def oclass
        Oriented.connection.graph.get_vertex_type(Oriented::Registry.odb_class_for(self.name.to_s)) 
      end
    end
  end
end
