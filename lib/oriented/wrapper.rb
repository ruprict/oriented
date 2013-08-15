require 'active_support/concern'

module Oriented
  module Wrapper 
    extend ActiveSupport::Concern

    attr_accessor :__java_obj

    def __java_obj
      @__java_obj 
    end

    def self.wrapper(java_obj)
      return java_obj if java_obj.element_type == 'Edge' 
      classname = java_obj.label
      clname = Oriented::Registry.ruby_class_for(classname)
      new_instance = to_class(clname).orig_new

      new_instance.__java_obj = java_obj
      new_instance

    end

    # @param [String] class_name the name we want the Class for
    # @return [Class] the class corresponding to the given name
    def self.to_class(class_name)
      class_name.split("::").inject(Kernel) { |container, name| container.const_get(name.to_s) }
    end

    # alias_method :wrap, :wrapper    

    Oriented::Core::JavaVertex.wrapper_proc=method(:wrapper)
    Oriented::Core::JavaEdge.wrapper_proc=method(:wrapper)


  end
end
