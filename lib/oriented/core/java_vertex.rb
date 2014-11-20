module Oriented
  module Core
    class JavaVertex
        extend Oriented::Core::Vertex::ClassMethods    
        extend Oriented::Core::Wrapper::ClassMethods

        include Oriented::Core::Property
        include Oriented::Core::Vertex
        include Oriented::Core::Rels           
        include Oriented::Core::Wrapper     
        
        def exist?
          Oriented::Core::JavaVertex.exist?(self)
        end

        # Overrides the class so that the java object feels like a Ruby object.
        def class
          Oriented::Core::JavaVertex
        end

        class << self

          def extend_java_class(java_clazz)
            java_clazz.class_eval do

              include Oriented::Core::Property
              include Oriented::Core::Vertex
              include Oriented::Core::Rels          
              include Oriented::Core::Wrapper         
              
              def class
                Oriented::Core::JavaVertex
              end     

            end
          end
        end

      end
      Oriented::Core::JavaVertex.extend_java_class(Java::ComTinkerpopBlueprintsImplsOrient::OrientVertex)
  end
end
