module Oriented
  module IdentityMap

    class << self
      def enable
        Thread.current[:odb_identity_map] = true
      end

      def disable
        Thread.current[:odb_identity_map] = false
      end

      def enabled?
        Thread.current[:odb_identity_map] == true
      end

      def vertex_repository
        Thread.current[:vertex_identity_map] ||= java.util.HashMap.new
      end

      def edge_repository
        Thread.current[:edge_identity_map] ||= java.util.HashMap.new
      end

      def repository_for(odb_entity)
        return nil unless enabled?
        if odb_entity.class == Oriented::Core::JavaVertex
          vertex_repository
        elsif odb_entity.class == Oriented::Core::JavaEdge
          edge_repository
        else
          nil
        end
      end

      def use
        old, self.enabled = enabled, true
        yield if block_given?
      ensure
        self.enabled = old
        clear
      end

      def without
        old, self.enabled = enabled, false
        yield if block_given?
      ensure
        self.enabled = old
      end

      def get(odb_entity)
        r = repository_for(odb_entity)
        r && r.get(odb_entity.id.to_s)
      end

      def add(odb_entity, wrapped_entity)
        r = repository_for(odb_entity)
        r && r.put(odb_entity.id.to_s, wrapped_entity)
      end

      def remove(odb_entity)
        r = repository_for(odb_entity)
        r && r.remove(odb_entity.id.to_s)
      end

      def remove_vertex_by_id(vertex_id)
        vertex_repository.remove(vertex_id)
      end

      def remove_edge_by_id(edge_id)
        edge_repository.remove(edge_id)
      end

      def clear
        vertex_repository.clear
        edge_repository.clear
      end

      def all
        vertex_repository.merge(edge_repository)
      end

      #TODO: PUt in hooks for commit?
    end

  end
end
