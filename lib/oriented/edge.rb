module Oriented
  module Edge
    extend ActiveSupport::Concern
    include Oriented::Edge::Delegates    
    include Oriented::Persistence    
    include Oriented::Properties
    include Oriented::Wrapper
    include Oriented::ClassName    


    def self.included(base)
      base.extend(ClassMethods)
      base.extend Oriented::Wrapper::ClassMethods      
    end
    
     def wrapper
       self
     end       

    module ClassMethods 

      def new(*args)
        validate_constructor_args(*args)
        start_vertex, end_vertex, label, props = *args
        wrapper = super()
        java_obj = Oriented::Core::JavaEdge.new(start_vertex.__java_obj, end_vertex.__java_obj, label)        
        wrapper.__java_obj = java_obj
        wrapper.write_default_values
        props.each_pair {|attr,val| wrapper.public_send("#{attr}=", val)} if props       
        wrapper
      end

      def find(id)
        edge = Oriented.graph.get_edge(id)
        return nil unless edge
        edge.wrapper
      end

      def find_all
        Oriented.graph.get_vertices_of_class(Oriented::Registry.odb_class_for(self.name.to_s), false)  
      end

      def to_adapter 
         self
      end


      private

      def validate_constructor_args(*args)
        start_vertex, end_vertex, label, props = *args
        raise ArgumentError.new "Start vertex not supplied" unless start_vertex
        raise ArgumentError.new "Start vertex is not a vertex" unless start_vertex.is_a?(Vertex)
        raise ArgumentError.new "End vertex not supplied" unless end_vertex
        raise ArgumentError.new "End vertex is not a vertex" unless end_vertex.is_a?(Vertex)
      end
      
    end
  end
end
