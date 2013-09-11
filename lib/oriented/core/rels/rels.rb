module Oriented
  module Core
    # Contains methods for traversing relationship object of depth one from one node.
    module Rels
      
      
        # Finds relationship starting from this node given a direction and/or relationship type(s).
        # @param (see #rels)
        # @return [Enumerable] of Neo4j::Relationship objects
        def _rels(dir=:both, *types)
          self.load
          if types.size > 1
            get_edges(ToJava.dir_to_java(dir), ToJava.types_to_java(types)).iterator
          elsif types.size == 1
            get_edges(ToJava.dir_to_java(dir), types[0].to_s.to_java).iterator #ToJava.type_to_java(types[0])).iterator
          else
            get_edges(ToJava.dir_to_java(dir)).iterator
          end
        end
        
        def _rel(dir, type)
          get_edges(ToJava.dir_to_java(dir), type.to_s.to_java).first
        end
        
        def rels(dir=:both, *types)
          _rels(dir, *types)
        end
        # def rels(dir=:both, *types)
        #   raise "Illegal argument, first argument must be :both, :incoming or :outgoing, got #{dir.inspect}" unless [:incoming, :outgoing, :both].include?(dir)
        #   Neo4j::Core::Rels::Traverser.new(self, types, dir)
        # end
        
        
        # def _other_vertex(vertex)
        #   if record.field("in").equals(vertex)
        #     record.field("out")
        #   else
        #     record.field("in")
        #   end
        # end
# 
# 
#       # Returns the only node of a given type and direction that is attached to this node, or nil.
#       # This is a convenience method that is used in the commonly occuring situation where a node has exactly zero or one relationships of a given type and direction to another node.
#       # Typically this invariant is maintained by the rest of the code: if at any time more than one such relationships exist, it is a fatal error that should generate an exception.
# 
#       # This method reflects that semantics and returns either:
#       # * nil if there are zero relationships of the given type and direction,
#       # * the relationship if there's exactly one, or
#       # * throws an unchecked exception in all other cases.
#       #
#       # This method should be used only in situations with an invariant as described above. In those situations, a "state-checking" method (e.g. #rel?) is not required,
#       # because this method behaves correctly "out of the box."
#       #
#       # @param (see #rel)
#       # @see Neo4j::Core::Node#wrapper #wrapper - The method used to wrap the node in a Ruby object if the node was found
#       def node(dir, type)
#         n = _node(dir, type)
#         n && n.wrapper
#       end
# 
#       # Same as #node but instead returns an unwrapped native java node.
#       # @param (see #rel)
#       def _node(dir, type)
#         r = _rel(dir, type)
#         r && r._other_node(self._java_node)
#       end
# 
#       # Works like #rels method but instead returns the nodes.
#       # @param (see #rels)
#       # @see #rels
#       # @return [Enumerable<Neo4j::Node>]
#       def _nodes(dir, *types)
#         r = _rels(dir, *types)
#         case dir
#           when :outgoing then
#             Neo4j::Core::LazyMap.new(r, &:_end_node)
#           when :incoming then
#             Neo4j::Core::LazyMap.new(r, &:_start_node)
#           when :both then
#             Neo4j::Core::LazyMap.new(r) { |x| x._other_node(self) }
#         end
#       end
# 
#       # Works like #rels method but instead returns the nodes.
#       # It does try to load a Ruby wrapper around each node
#       # @param (see #rels)
#       # @see Neo4j::Core::Node#wrapper #wrapper - The method used wrap to the node in a Ruby object if the node was found
#       # @return [Enumerable] an Enumeration of either Neo4j::Node objects or wrapped Neo4j::Node objects
#       # @notice it's possible that the same node is returned more then once because of several relationship reaching to the same node, see #outgoing for alternative
#       def nodes(dir, *types)
#         Neo4j::Core::LazyMap.new(_nodes(dir, *types), &:wrapper)
#       end
# 
# 
#       # Returns an enumeration of relationship objects using the builder DSL pattern.
#       # It always returns relationships of depth one.
#       #
#       # @param [:both, :incoming, :outgoing] dir the direction of the relationship
#       # @param [String, Symbol] types the requested relationship types we want look for, if none it gets relationships of any type
#       # @return [Neo4j::Core::Rels::Traverser] an object which included the Ruby Enumerable mixin
#       #
#       # @example Return both incoming and outgoing relationships
#       #   me.rels(:both, :friends, :work).each {|relationship|...}
#       #
#       # @example Only return outgoing relationship of given type
#       #   me.rels(:outgoing, :friends).first.end_node # => my friend node
#       #
#       # @example All the relationships between me and another node of given dir & type
#       #   me.rels(:outgoing, :friends).to_other(node)
#       #
#       # @example Delete all relationships between me and another node of given dir & type
#       #   me.rels(:outgoing, :friends).to_other(node).del
#       #
#       # @see Neo4j::Core::Node#wrapper #wrapper - The method used wrap to the node in a Ruby object if the node was found
#       # @see Neo4j::Relationship#rel_type
#       # @raise an exception if the first parameter is not <tt>:both</tt>, <tt>;outgoing</tt> or <tt>:incoming</tt>
#       def rels(dir=:both, *types)
#         raise "Illegal argument, first argument must be :both, :incoming or :outgoing, got #{dir.inspect}" unless [:incoming, :outgoing, :both].include?(dir)
#         Neo4j::Core::Rels::Traverser.new(self, types, dir)
#       end
# 
# 
#       # Returns the only relationship of a given type and direction that is attached to this node, or null.
#       # This is a convenience method that is used in the commonly occuring situation where a node has exactly zero or
#       # one relationships of a given type and direction to another node.
#       # Typically this invariant is maintained by the rest of the code: if at any time more than one such relationships
#       # exist, it is a fatal error that should generate an unchecked exception. This method reflects that semantics and
#       # returns either:
#       #
#       # * nil if there are zero relationships of the given type and direction,
#       # * the relationship if there's exactly one, or
#       # * raise an exception in all other cases.
#       # @param [:both, :incoming, :outgoing] dir the direction of the relationship
#       # @param [Symbol, String] type the type of relationship, see Neo4j::Core::Relationship#rel_type
#       # @return [Neo4j::Relationship, nil, Object] the Relationship or wrapper for the Relationship or nil
#       # @see Neo4j::Core::Relationship#rel_type
#       # @see Neo4j::Core::Node#wrapper #wrapper - The method used to wrap the node in a Ruby object if the node was found
#       def rel(dir, type)
#         result = _rel(dir, type)
#         result && result.wrapper
#       end
# 
#       # Same as rel but does not return a ruby wrapped object but instead returns the Java object.
#       # @param (see #rel)
#       # @return [Neo4j::Relationship, nil]
#       # @see #rel
#       def _rel(dir, type)
#         get_single_relationship(ToJava.type_to_java(type), ToJava.dir_to_java(dir))
#       end
# 
#       # Finds relationship starting from this node given a direction and/or relationship type(s).
#       # @param (see #rels)
#       # @return [Enumerable] of Neo4j::Relationship objects
#       def _rels(dir=:both, *types)
#         if types.size > 1
#           get_relationships(ToJava.dir_to_java(dir), ToJava.types_to_java(types)).iterator
#         elsif types.size == 1
#           get_relationships(ToJava.type_to_java(types[0]), ToJava.dir_to_java(dir)).iterator
#         else
#           get_relationships(ToJava.dir_to_java(dir)).iterator
#         end
#       end
# 
# 
#       # Check if the given relationship exists
#       # Returns true if there are one or more relationships from this node to other nodes
#       # with the given relationship.
#       #
#       # @param [:both, :incoming, :outgoing] dir  optional default :both (either, :outgoing, :incoming, :both)
#       # @param [String,Symbol] type the key and value to be set, default any type
#       # @return [Boolean] true if one or more relationships exists for the given type and dir otherwise false
#       def rel?(dir=:both, type=nil)
#         if type
#           has_relationship(ToJava.type_to_java(type), ToJava.dir_to_java(dir))
#         else
#           has_relationship(ToJava.dir_to_java(dir))
#         end
#       end
# 
    end

  end


end