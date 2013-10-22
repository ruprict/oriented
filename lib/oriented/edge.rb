module Oriented
  module Edge
    extend ActiveSupport::Concern
    include Oriented::Edge::Delegates    
    include Oriented::Wrapper    
    include Oriented::EdgeMethods    
    include Oriented::Persistence  
    include Oriented::EdgePersistence        
    include Oriented::Properties
    include Oriented::ClassName    


    # def self.included(base)
    #   base.extend(ClassMethods)
    #   base.extend Oriented::Wrapper::ClassMethods      
    # end
    
     def wrapper
       self
     end       

  end
end
