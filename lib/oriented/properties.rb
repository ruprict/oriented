module Oriented
  module Properties
    extend ActiveSupport::Concern

    RESTRICTED_PROPERTIES = [:_orient_id]

    class RestrictedPropertyError < StandardError; end

    def self.included(base)
      base.extend ClassMethods 
    end
    
    def props
      ret = {}
      property_names.each do |property_name|
        ret[property_name] = respond_to?(property_name) ? send(property_name) : send(:[], property_name)
      end
      ret      
    end
    
    def property_names 
      @_properties ||= {}
      keys = @_properties.keys + self.class._props.keys.map(&:to_s)      
      keys += __java_obj.property_keys.to_a if __java_obj
      keys.flatten.uniq
    end

    module ClassMethods

      def attribute_defaults
        @attribute_defaults ||= {}
      end

      def _props
        @_props ||= {}
      end

      def property(*props)
        options = props.last.kind_of?(Hash) ? props.pop : {}
        props.each do |prop|
          raise RestrctedPropertyError if RESTRICTED_PROPERTIES.include?(prop)
          next if _props.has_key?(prop)
          _props[prop] ||= {}
          options.each {|k, v| _props[prop][k] = v}
          
          attribute_defaults[prop] = options[:default]  if options.has_key?(:default)
          _props[prop][:converter] ||= Oriented::TypeConverters.converter(_props[prop][:type])

          create_property_methods(prop)
        end

      end

      def create_property_methods(name)
        define_method "#{name}" do
          self.class._converter(name).to_ruby(__java_obj.get_property(name.to_s))
        end

        define_method "#{name}=" do |val|
          __java_obj.send(:[]=, name.to_s, self.class._converter(name).to_java(val))
        end
        
      end

      def _converter(pname)
        prop = _props[pname]
        (prop && prop[:converter]) || Oriented::TypeConverters::DefaultConverter
      end
    end

    def write_default_values
      self.class.attribute_defaults.each_pair do |attr, val| 
        self.send("#{attr}=", val)
      end
    end
  end
end
