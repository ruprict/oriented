module Oriented
  module Edge
    extend ActiveSupport::Concern
    include Oriented::Edge::Delegates    
    include Oriented::Persistence    
    include Oriented::Properties
    include Oriented::Wrapper


    def self.included(base)
      base.extend(ClassMethods)
      base.extend Oriented::Wrapper::ClassMethods      
    end
    
     def wrapper
       self
     end       

    module ClassMethods 

      def new(*args)
        start_vertex, end_vertex, label, props = *args
        wrapper = super()
        java_obj = Oriented::Core::JavaEdge.new(start_vertex.__java_obj, end_vertex.__java_obj, label)        
        wrapper.__java_obj = java_obj
        wrapper.write_default_values
        props.each_pair {|attr,val| wrapper.public_send("#{attr}=", val)} if props       
        wrapper
      end
      
      def to_adapter 
         self
      end
      
    end
  end
end
