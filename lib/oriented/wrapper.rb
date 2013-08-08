require 'active_support/concern'

module Oriented
  module Wrapper 
    extend ActiveSupport::Concern
    # def self.included(base)
    #   base.extend ClassMethods
    # end

    def self.wrapper(java_obj)

      classname = java_obj.element_type == 'Edge' ? "Oriented::Edge" : java_obj.label
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
    def self.to_class(class_name)
      class_name.split("::").inject(Kernel) { |container, name| container.const_get(name.to_s) }
    end

    # alias_method :wrap, :wrapper    


    # extend self

    Oriented::Core::JavaVertex.wrapper_proc=method(:wrapper)
    Oriented::Core::JavaEdge.wrapper_proc=method(:wrapper)


  end
end
