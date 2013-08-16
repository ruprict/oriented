module Oriented
  module Relationships
    class EdgesInstance
      include Enumerable
      def initialize(vertex, rel_type)
        @vertex = vertex
        @rel_type = rel_type
      end  

      def each
        edge_query.each do |v|
          yield v.wrapper
          # yield self.class.wrap(v)
        end
      end

      def create_relationship_to(other, attrs={})
        vertex.add_edge(@rel_type.label, other.__java_obj, nil, nil, attrs)
      end

      def to_other(other_vertex)
        vertex.get_edges(other_vertex.__java_obj, @rel_type.direction).to_a
      end


      private

      def edge_query
        vertex.query().labels(@rel_type.label).edges()
      end

      def vertex
        @vertex.__java_obj
      end
    end
  end
end
