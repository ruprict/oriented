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
        dir = @rel_type.direction == Oriented::Relationships::Direction::IN ? "in" : "out"
        other_dir = dir == "out" ? "in" : "out"
        f =  vertex.record.field("#{dir}_#{@rel_type.label}")
        rec = case f
        when Java::ComOrientechnologiesOrientCoreTypeTree::OMVRBTreeRIDSet
          f.select {|e| e.field(other_dir).get_identity().to_s == (other_vertex.id) }.first
        else
          f.field(other_dir) if f.field(other_dir).get_identity().to_s == (other_vertex.id)
        end
        OrientDB::BLUEPRINTS::impls::orient::OrientEdge.new(vertex.graph, rec) if rec
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
