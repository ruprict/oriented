module Oriented
  # Responsible for loading the correct Ruby wrapper class for the Neo4j Entity
  module Wrapper
    module ClassMethods
      # Loads the wrapper by using the original new method and initialize it
      # @private
      def _load_wrapper(node)
        wrapped_node = self.orig_new
        # wrapped_node.init_on_load(node)
        wrapped_node
      end

      # def setup_neo4j_subclass(sub_klass)
      #   return if self.to_s == sub_klass.to_s
      #   # make the base class trigger on the sub class nodes
      #   _indexer.config.trigger_on :_classname => sub_klass.to_s
      # 
      #   sub_klass.inherit_rules_from(self) if sub_klass.respond_to?(:inherit_rules_from)
      # 
      #   if sub_klass.ancestors.include?(Neo4j::NodeMixin)
      #     setup_node_index(sub_klass)
      #   else
      #     setup_rel_index(sub_klass)
      #   end
      # 
      #   superclass.setup_neo4j_subclass(sub_klass) if superclass.respond_to?(:setup_neo4j_subclass)
      # end
      # 
      # def setup_node_index(sub_klass=self)
      #   base_class = self
      #   sub_klass.node_indexer do
      #     inherit_from base_class unless base_class == sub_klass
      #     index_names :exact => "#{sub_klass._index_name}_exact", :fulltext => "#{sub_klass._index_name}_fulltext"
      #     trigger_on :_classname => sub_klass.to_s
      #     prefix_index_name &sub_klass.method(:index_prefix)
      #   end
      # end
      # 
      # def setup_rel_index(sub_klass=self)
      #   base_class = self
      #   sub_klass.rel_indexer do
      #     inherit_from base_class unless base_class == sub_klass
      #     index_names :exact => "#{sub_klass._index_name}_exact", :fulltext => "#{sub_klass._index_name}_fulltext"
      #     trigger_on :_classname => sub_klass.to_s
      #     prefix_index_name &sub_klass.method(:index_prefix)
      #   end
      # end

      # Creates an alias to the original new method:  <tt>orig_new</tt>
      # @private
      def self.extended(klass)
        klass.instance_eval do
          class << self
            alias_method :orig_new, :new
          end
        end unless klass.respond_to?(:orig_new)
        super
      end
    end
  end
end


