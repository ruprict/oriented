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


