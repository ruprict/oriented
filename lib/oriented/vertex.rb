require 'active_support/concern'

module Oriented
  module Vertex
    extend ActiveSupport::Concern
    include Oriented::Vertex::Delegates    

    include Oriented::Wrapper      
    include Oriented::VertexMethods
    include Oriented::Persistence  
    include Oriented::VertexPersistence          
    include Oriented::ClassName      
    include Oriented::Relationships
    # extend Oriented::Wrapper::ClassMethods
        

    include Oriented::Properties


    # def self.included(base)
    #   # base.extend Oriented::Wrapper::ClassMethods      
    #   base.extend Oriented::Vertex::MyMethods
    # end

    # def persisted?
    #   __java_obj.id.persistent?
    # end
    
     def wrapper
       self
     end       
     

    protected



  end
end

