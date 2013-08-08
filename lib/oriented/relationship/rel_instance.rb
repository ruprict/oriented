module Oriented
  module Relationship
    class RelInstance
      include Enumerable
      # include Oriented::Wrapper

      def initialize(vertex, rel_type)
        @vertex = vertex
        @rel_type = rel_type
        check_edge_type(@rel_type.label)
      end  

      def each
        vertex_query.each do |v|
          yield v.wrapper
          # yield self.class.wrap(v)
        end
      end

      def other_vertex
        return unless @rel_type.cardinality == :one
        vertex_query.first.wrapper 
      end

      def << (other)
        return if @rel_type.cardinality == :one
        create_relationship_to(other)
      end

      def create_relationship_to(other)
        vertex.add_edge(@rel_type.label.to_s, other.__java_obj)
      end

      def destroy_relationship
        edge_query.each {|e| e.remove}
      end
      
      def destroy_relationship_to(other)
        edge_query.each do |e| 
          if e.out_vertex.id == other.id || e.in_vertex.id == other.id
            e.remove
          end
        end
      end

      private

      def vertex_query
        vertex.query().labels(@rel_type.label).vertices()
      end

      def edge_query
        vertex.query().labels(@rel_type.label).edges()
      end

      def vertex
        @vertex.__java_obj
      end

      def check_edge_type(rel_label)
        exists = vertex.graph.get_edge_type(rel_label.to_s)
        unless exists
          vertex.graph.create_edge_type(rel_label.to_s)
        end
      end
    end
  end
end
