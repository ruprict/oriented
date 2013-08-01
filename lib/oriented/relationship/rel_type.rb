module Oriented
  module Relationship
    class RelType

      attr_reader :direction, :cardinality, :label
   
      def initialize(rel_label, source_class, options={})
        @label = rel_label
        @source_class = source_class
        @direction = options.fetch(:dir, Oriented::Relationships::Direction::OUT) 
        @cardinality = options.fetch(:cardinality, :many)
      end

    end
  end
end
