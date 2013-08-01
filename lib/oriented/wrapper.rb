require 'active_support/concern'

module Oriented
  module Wrapper 
    extend ActiveSupport::Concern
    def self.included(base)
      base.extend ClassMethods
    end

    def wrap(java_obj)
      self.class.wrap(java_obj) 
    end

    module ClassMethods
      def wrap(java_obj)
        c = Object.const_get(java_obj.label)  
        model = c.new
        model.__java_obj = java_obj
        model
      end
    end
  end
end
