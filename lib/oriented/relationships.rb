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
    
    # @private
    def initialize_relationships
      @_relationships = {}
    end

    # @private
    def write_changed_relationships #:nodoc:
      @_relationships.each_value do |storage|
        storage.persist
      end
    end

    # @private
    def relationships_changed?
      @_relationships.each_value do |storage|
        return true if !storage.persisted?
      end
      false
    end

    # @private
    def clear_relationships
      # @_relationships && @_relationships.each_value { |storage| storage.remove_from_identity_map }
      initialize_relationships
    end
    
    def add_unpersisted_rel(label, rel)
      _create_or_get_vertex_instance(label).add_unpersisted_rel(rel)      
    end
    
    def add_rel(label, rel)
      _create_or_get_vertex_instance(label).add_rel(rel)      
    end    

    def add_incoming_rel(label, rel)
      _create_or_get_vertex_instance(label).add_incoming_rel(rel)
    end

    def add_outgoing_rel(label, rel)
      _create_or_get_vertex_instance(label).add_outgoing_rel(rel)      
    end
    
    # Makes the given relationship available in callbacks
    def add_unpersisted_incoming_rel(label, rel)
      _create_or_get_vertex_instance(label, "IN").add_unpersisted_rel(rel) #add_unpersisted_incoming_rel(rel)      
    end

    # Makes the given relationship available in callbacks
    def add_unpersisted_outgoing_rel(label, rel)
      _create_or_get_vertex_instance(label, "OUT").add_unpersisted_rel(rel) #add_unpersisted_outgoing_rel(rel)
    end
    
    def rm_incoming_rel(label, rel)
      _create_or_get_vertex_instance(label).rm_incoming_rel(rel)      
    end

    def rm_outgoing_rel(label, rel)
      _create_or_get_vertex_instance(label).rm_outgoing_rel(rel)
    end

    def rm_unpersisted_incoming_rel(label, rel)
      _create_or_get_vertex_instance(label).rm_unpersisted_incoming_rel(rel)
    end

    def rm_unpersisted_outgoing_rel(label, rel)
      _create_or_get_vertex_instance(label).rm_unpersisted_outgoing_rel(rel)
    end

    def _create_or_get_vertex_instance(label, dir='OUT') #:nodoc:
      # puts "inside create or get vertex instance for decl rels label = #{label} and class = #{self.class}"
      # puts "class rels = #{self.class._rels[label.to_sym].inspect}"
      
      self.class._rels[label.to_sym] = Oriented::Relationships::RelType.new(label, self, {cardinality: :many, dir:dir.downcase}) if !self.class._rels[label.to_sym]
      decl_rels = self.class._rels[label.to_sym]
      @_relationships["#{decl_rels.label.to_s}_#{dir}".to_sym] ||= Oriented::Relationships::VertexInstance.new(self, decl_rels)
    end
      
    def _create_or_get_vertex_instance_for_decl_rels(decl_rels) #:nodoc:
      @_relationships["#{decl_rels.label.to_s}_#{decl_rels.direction.to_s}".to_sym] ||= Oriented::Relationships::VertexInstance.new(self, decl_rels)
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
              rel_instance = _create_or_get_vertex_instance_for_decl_rels(rel)
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
              rel_instance = _create_or_get_vertex_instance_for_decl_rels(rel)
              other_v = rel_instance.other_vertex
              other_v.wrapper if other_v
            end
          RUBY
        end

        unless method_defined?("#{method_name}=")
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name}=(other)
             rel = self.class._rels[:'#{method_name}']
             rel_instance = _create_or_get_vertex_instance_for_decl_rels(rel)
             rel_instance.destroy_relationship
             rel_instance.create_relationship_to(other)
            end
          RUBY
        end

        unless method_defined?("#{method_name}_rel")
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name}_rel
              rel = self.class._rels[:'#{method_name}']
              rel_instance = Oriented::Relationships::EdgesInstance.new(self, rel).first
              rel_instance.wrapper if rel_instance
            end
          RUBY
        end

        _rels[method_name] = Relationships::RelType.new(method_name, self, options.merge({cardinality: :one}))
      end 

    end # ClassMethods

  end
end
