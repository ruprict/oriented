module Oriented
  module Relationships
    class VertexInstance
      include Enumerable

      def initialize(vertex, rel_type)
        @vertex = vertex
        @rel_type = rel_type
        #check_edge_type(@rel_type.label)
      end  

      def each
        vertex_query.each do |v|
          yield v.wrapper
          # yield self.class.wrap(v)
        end
      end
      
      def create(node_attr = {}, rels_attrs = {})
        objcls = @rel_type.target_class.constantize || Oriented::Core::JavaVertex
        v = objcls.new(node_attr)
        rel = self.create_relationship_to(v, rels_attrs)
        v
      end
      
      def empty?
        return !other_vertex if @rel_type.cardinality == :one
        first == nil
      end

      def other_vertex
        return unless @rel_type.cardinality == :one
        other = vertex_query.first
        other.wrapper if other
      end

      def <<(other, attrs={})
        return if @rel_type.cardinality == :one
        create_relationship_to(other, attrs)
        other
      end

      def create_relationship_to(other, attrs={})
        vertex.add_edge(@rel_type.label.to_s, other.__java_obj, nil, nil, attrs).wrapper
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
