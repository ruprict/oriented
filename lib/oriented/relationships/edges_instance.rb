module Oriented
  module Relationships
    class EdgesInstance
      include Enumerable
      extend Oriented::Core::TransactionWrapper

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
        vertex.add_edge(@rel_type.label, other.__java_obj, nil, nil, attrs).wrapper
      end
      wrap_in_transaction :create_relationship_to

      def to_other(other_vertex)
        vertex.get_edges(other_vertex.__java_obj, @rel_type.direction, @rel_type.label).to_a.map{|e| e.wrapper}
      end

      def empty?
        edge_query.count == 0
      end

      def as_query
        vertex.query().labels(@rel_type.label)
      end

      private

      def edge_query
        as_query.edges()
      end

      def vertex
        @vertex.__java_obj
      end
    end
  end
end
