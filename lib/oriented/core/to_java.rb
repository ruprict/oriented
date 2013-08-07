module Oriented
  module Core
    # A Utility class for translating Ruby object to Neo4j Java types
    # @private
    module ToJava
      def type_to_java(type)
        # Java::OrgNeo4jGraphdb::DynamicRelationshipType.withName(type.to_s)
      end

      module_function :type_to_java

      def types_to_java(types)
        # types.inject([]) { |result, type| result << type_to_java(type) }.to_java(Java::OrgNeo4jGraphdb::RelationshipType)
      end

      module_function :types_to_java


      def dir_from_java(dir)
        case dir
          when OrientDB::BLUEPRINTS::Direction::OUT then
            :outgoing
          when OrientDB::BLUEPRINTS::Direction::BOTH then
            :both
          when OrientDB::BLUEPRINTS::Direction::IN then
            :incoming
          else
            raise "unknown direction '#{dir} / #{dir.class}'"
        end
      end

      module_function :dir_from_java

      def dir_to_java(dir)
        case dir
          when :outgoing then
            OrientDB::BLUEPRINTS::Direction::OUT
          when :both then
            OrientDB::BLUEPRINTS::Direction::BOTH
          when :incoming then
            OrientDB::BLUEPRINTS::Direction::IN
          else
            raise "unknown direction '#{dir}', expects argument: outgoing, :incoming or :both"
        end
      end

      module_function :dir_to_java

    end
  end
end