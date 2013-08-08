require 'active_support/concern'

module Oriented
  module Wrapper 
    extend ActiveSupport::Concern
    # def self.included(base)
    #   base.extend ClassMethods
    # end

    def wrapper(java_obj)
      
      puts "INSIDE WRapper"
      puts java_obj.label
      classname = java_obj.element_type == 'Edge' ? "Oriented::Edge" : java_obj.label
      puts classname
      new_instance = to_class(classname).orig_new
      new_instance.__java_obj = java_obj
      new_instance
      
      # c = Object.const_get(java_obj.label)  
      # model = c.new
      # model.__java_obj = java_obj
      # model
    end
    
    
    
    # @param [String] class_name the name we want the Class for
    # @return [Class] the class corresponding to the given name
    def to_class(class_name)
      class_name.split("::").inject(Kernel) { |container, name| container.const_get(name.to_s) }
    end

    # alias_method :wrap, :wrapper    
    
    
    extend self

    Oriented::Core::JavaVertex.wrapper_proc=method(:wrapper)
    Oriented::Core::JavaEdge.wrapper_proc=method(:wrapper)
    
    

            # alias_method :self.orig_new, :self.initialize            
            
    # module ClassMethods
    # 
    #   def self.extended(klass)
    #     puts "self extended"
    #     klass.instance_eval do
    #       class << self
    #         # alias_method :orig_new, :new
    #         alias_method :orig_new, :new       
    #            
    #       end
    #     end unless klass.respond_to?(:orig_new)
    #     super
    #   end
    # 
    # 
    # 
    #   
    #   # alias_method :orig_new, :initialize
    # 
    #   
    # end
  end
end
