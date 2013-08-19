module Oriented
  module Relationships
    class RelType

      attr_reader :direction, :cardinality, :label, :target_class
   
      def initialize(rel_label, source_class, options={})
        @label = rel_label.to_s
        @source_class = Oriented::Registry.odb_class_for(source_class)

        @direction = get_direction(options.fetch(:dir, Oriented::Relationships::Direction::OUT) )
        @cardinality = options.fetch(:cardinality, :many)
      end


      def to(*args)
        @direction = Oriented::Relationships::Direction::OUT
        if Class === args[0] 
          @target_class = Oriented::Registry.odb_class_for(args[0])
          @label = "#{@source_class}__#{@label}"
        elsif Symbol === args[0]
          @label = args[0].to_s
        end

        self
        
      end

      def from(*args)
        @direction = Oriented::Relationships::Direction::IN 

        if args.size > 1
          @target_class = Oriented::Registry.odb_class_for(args[0])
          @label = "#{@target_class}__#{args[1].to_s}"
        elsif Symbol === args[0]
          @label = args[0].to_s
        end
        self
      end

      def relationship(rel_class)
        @relationship_class = rel_class
        self
      end

      def relationship_class
        @relationship_class ||= Oriented::Core::JavaEdge 
      end

      private

      def get_direction(dir)
        @direction ||= case dir
        when Direction
          dir
        when String
          if (dir =~ /out/i) == 0
            @direction = Direction::OUT
          elsif ( dir =~ /in/i ) == 0 
            @direction = Direction::IN
          end
        else
          raise ArgumentError.new("Unknown Direction")
        end
      end

    end
  end
end
