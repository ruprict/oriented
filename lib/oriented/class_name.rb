module Oriented
  module ClassName
    extend ActiveSupport::Concern
    
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def odb_class_name=(val)
        @_obd_class_name = val
      end

      def odb_class_name
        @_obb_class_name ||= name.to_s 
      end
    end
  end
end
