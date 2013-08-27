require 'active_support/concern'
require 'orientdb'

module Oriented
  module Relationships
    extend ActiveSupport::Concern

    Direction = OrientDB::BLUEPRINTS::Direction

    def self.included(base)
      base.extend ClassMethods
    end
    
    def rels(dir=:both, *types)
      _rels(dir, *types).collect{|r| r.wrapper }
    end

    module ClassMethods
      def _rels
        @rels ||= {}
      end

      def has_n(rel_label, options={})
        method_name = rel_label.downcase
        unless method_defined?(method_name)
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name} 
              rel = self.class._rels[:'#{method_name}']  
              rel_instance = Oriented::Relationships::VertexInstance.new(self, rel)
            end
          RUBY
        end

        unless method_defined?("#{method_name}_rels")
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name}_rels
              rel = self.class._rels[:'#{method_name}']
              rel_instance = Oriented::Relationships::EdgesInstance.new(self, rel)
            end
          RUBY
        end
        _rels[rel_label] = Oriented::Relationships::RelType.new(rel_label, self, options.merge({cardinality: :many}))
      end

      def has_one(rel_label, options={})
        method_name = rel_label.downcase
        unless method_defined?(method_name)
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name} 
              rel = self.class._rels[:'#{method_name}']
              rel_instance = Oriented::Relationships::VertexInstance.new(self, rel)
              rel_instance.other_vertex
            end
          RUBY
        end

        unless method_defined?("#{method_name}=")
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name}=(other)
             rel = self.class._rels[:'#{method_name}']
             rel_instance = Oriented::Relationships::VertexInstance.new(self, rel)
             rel_instance.destroy_relationship
             rel_instance.create_relationship_to(other)
            end
          RUBY
        end

        unless method_defined?("#{method_name}_rel")
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name}_rel
              rel = self.class._rels[:'#{method_name}']
              rel_instance = Oriented::Relationships::EdgesInstance.new(self, rel).first.wrapper
            end
          RUBY
        end

        _rels[method_name] = Relationships::RelType.new(method_name, self, options.merge({cardinality: :one}))
      end 

    end # ClassMethods

  end
end
