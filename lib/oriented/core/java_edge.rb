module Oriented
  module Core
    class JavaEdge
          extend Oriented::Core::Edge::ClassMethods    
          # extend OrientDB::Core::Wrapper::ClassMethods
          # 
          include Oriented::Core::Property
          include Oriented::Core::Edge
          include Oriented::Core::Rels           
          # include OrientDB::Core::Wrapper
          def exist?
            Oriented::Core::JavaEdge.exist?(self)
          end

          # Overrides the class so that the java object feels like a Ruby object.
          # def class
          #   Oriented::Core::JavaEdge
          # end


          class << self

            def extend_java_class(java_clazz)
              java_clazz.class_eval do

                
                include Oriented::Core::Property
                include Oriented::Core::Edge          
                include Oriented::Core::Rels          
                # include OrientDB::Core::Wrapper     
                
                # def class
                #   Oriented::Core::JavaEdge
                # end     

              end
            end
          end

        end

        Oriented::Core::JavaEdge.extend_java_class(Java::ComTinkerpopBlueprintsImplsOrient::OrientEdge)
  end
end
