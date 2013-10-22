module Oriented 
  describe "EdgePerisistence" do
    let(:vertex_class) {define_test_class(Vertex)}  
    let(:vertex) {
      v = vertex_class.new
      v.save
      v
    }

    describe ".get!" do
      let(:end_vertex) {
        v = vertex_class.new
        v.save
        v
      }

      let(:edge_class) {define_test_class(Edge)}

      let(:edge) { 
        e = edge_class.new vertex, end_vertex, "knows"
        e.save
        e
      }

      describe ".get!" do
        it "returns an edge" do
          e = edge_class.get!(edge.id)
          e.should_not be_nil
        end
      end

    end
  end
end
