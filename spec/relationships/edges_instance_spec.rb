module Oriented
  module Relationships
    describe EdgesInstance do
      let(:dummy_class) { define_test_class(Vertex)}
      let(:related_class) { define_test_class(Vertex)}
      let(:vertex) { v = dummy_class.new; v.save; v}
      let(:rel_type) { RelType.new("spanks", dummy_class)}
      let(:other) {o= related_class.new; o.save; o}
      subject {described_class.new(vertex, rel_type)}

      describe "#create_relationship_to" do
        it "creates the relationship" do
          e = subject.create_relationship_to(other)
          subject.map(&:id).should include(e.id)
        end

        it "take properties" do
          e = subject.create_relationship_to(other, {prop1: "val1"})
          e["prop1"].should == "val1"
        end
       
        context "when a relationship has properties" do
          before(:each) do
            @rel_class = define_test_class(Edge)
            Oriented::Registry.map(@rel_class.name, "spanks")
          end

          it "returns a class" do
            e = subject.create_relationship_to(other, {prop1: "val1"})
            e.should be_a(@rel_class)
          end
        end
      end

      describe "#empty?" do
        it "returns true when no rels" do
          subject.empty?.should be_true

        end
      end

      describe "to_other" do
        context "without edge properties" do
          it "returns the edge from self to the other specified" do
            r = subject.create_relationship_to(other)
            Oriented.graph.commit
            e = subject.to_other(other)
            e.should_not be_nil 
          end  

          context "with more than one record" do
            let(:other2) {o= related_class.new; o.save; o}

            it "returns the right one, baby, uh-huh" do
              r1 = subject.create_relationship_to(other)
              r2 = subject.create_relationship_to(other2)
              Oriented.graph.commit
              e = subject.to_other(other)
              e.count.should == 1
              e.first.id.to_s.should == r1.id.to_s
            end
          end
        end

        context "with edge properties" do
          it "returns the edge from self to the other specified" do
            r = subject.create_relationship_to(other, {prop1: "val1"})
            Oriented.graph.commit
            e = subject.to_other(other).first
            e.should_not be_nil 
          end  

          context "with more than one record" do
            let(:other2) {o= related_class.new; o.save; o}

            it "returns the right one, baby, uh-huh" do
              r1 = subject.create_relationship_to(other, {prop1: "val1"})
              r2 = subject.create_relationship_to(other2, {prop1: "val2"})
              Oriented.graph.commit
              e = subject.to_other(other)
              e.count.should == 1
              e.first.id.to_s.should == r1.id.to_s
            end


          end
        end
      end
    end
  end
end
