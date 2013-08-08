# module OrientDB
#   module Wrapper
# 
#     # This method is used when loading Neo4j::Node objects
#     #
#     # Reads the <tt>_classname</tt> property and tries to load the ruby class.
#     # The Neo4j::Core gem will use this method, because the following:
#     #  Neo4j::Node.wrapper_proc=method(:wrapper)
#     #
#     # @param [Neo4j::Node, Neo4j:Relationship] entity the entity which might be wrapped
#     # @return [Object] a Ruby class wrapping the given entity
#     # @see Neo4j::Core::Wrapper.wrapper_proc=
#     def wrapper(entity)
#       # return entity unless entity.property?(:_classname)
#       # existing_instance = Neo4j::IdentityMap.get(entity)
#       # return existing_instance if existing_instance
#       # new_instance = to_class(entity[:_classname])._load_wrapper(entity)      
#       # Neo4j::IdentityMap.add(entity, new_instance)
#       
#       puts entity.label
#       classname = entity.element_type == 'Edge' ? "Oriented::Edge" : entity.label
#       puts classname
#       new_instance = to_class(classname)._load_wrapper(entity)      
#       new_instance
#     end
# 
#     # @param [String] class_name the name we want the Class for
#     # @return [Class] the class corresponding to the given name
#     def to_class(class_name)
#       class_name.split("::").inject(Kernel) { |container, name| container.const_get(name.to_s) }
#     end
# 
#     extend self
# 
#     OrientDB::Vertex.wrapper_proc=method(:wrapper)
#     OrientDB::Edge.wrapper_proc=method(:wrapper)
# 
# 
#   end
# 
# 
# end
# 
