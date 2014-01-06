module Oriented
  module Properties
    extend ActiveSupport::Concern

    RESTRICTED_PROPERTIES = [:_orient_id]

    class RestrictedPropertyError < StandardError; end
    
    included do |base|
      
      base.extend ClassMethods
      alias_method :read_property_from_db, :[]
      alias_method :write_property_to_db, :[]=
    
      # wrap the read/write in type conversion
      # alias_method_chain :read_attribute, :type_conversion
      # alias_method_chain :write_attribute, :type_conversion
      
      alias_method :read_attribute_without_type_conversion, :read_attribute
      alias_method :read_attribute, :read_attribute_with_type_conversion
      
      alias_method :write_attribute_without_type_conversion, :write_attribute
      alias_method :write_attribute, :write_attribute_with_type_conversion


    
      # whenever we refer to [] or []=. use our local properties store
      alias_method :[], :read_attribute
      alias_method :[]=, :write_attribute
      
    end
    
    def initialize_attributes(attributes)
      @_properties = {}
      @_properties_before_type_cast={}
      self.attributes = attributes if attributes
    end
    
    # Mass-assign attributes.  Stops any protected attributes from being assigned.
    def attributes=(attributes, guard_protected_attributes = true)
      # attributes = sanitize_for_mass_assignment(attributes) if guard_protected_attributes

      multi_parameter_attributes = []
      attributes.each do |k, v|
        # if k.to_s.include?("(")
        #   multi_parameter_attributes << [k, v]
        # else
          respond_to?("#{k}=") ? send("#{k}=", v) : self[k] = v
        # end
      end
    end
    
    # @private
    def reset_attributes
      @_properties = {}
    end
    
    # Wrap the getter in a conversion from Java to Ruby
    def read_attribute_with_type_conversion(property)
      self.class._converter(property).to_ruby(read_attribute_without_type_conversion(property))
    end

    # Wrap the setter in a conversion from Ruby to Java
    def write_attribute_with_type_conversion(property, value)
      @_properties_before_type_cast ||= {}
      @_properties_before_type_cast[property.to_sym]=value if self.class._props.has_key? property.to_sym
      conv_value = self.class._converter(property.to_sym).to_java(value)
      write_attribute_without_type_conversion(property, conv_value)
    end

      
    
    def props
      ret = {}
      property_names.each do |property_name|
        prval = self.respond_to?(property_name) ? send(property_name) : send(:[], property_name)
        ret[property_name] = prval if prval
      end
      ret      
    end
    
    def attribute_defaults
      self.class.attribute_defaults || {}
    end
    
    def property_names 
      @_properties ||= {}
      keys = @_properties.keys + self.class._props.keys.map(&:to_s)      
      keys += __java_obj.property_keys.to_a if __java_obj
      keys.flatten.uniq
    end
    
    def write_attribute(key, value)
      @_properties ||= {}      
      key_s = key.to_s
      if !@_properties.has_key?(key_s) || @_properties[key_s] != value
        # attribute_will_change!(key_s)
        @_properties[key_s] = value.nil? ? attribute_defaults[key_s] : value
      end
      value
    end

    # Returns the locally stored value for the key or retrieves the value from
    # the DB if we don't have one
    def read_attribute(key)
      @_properties ||= {}      
      key = key.to_s
      if @_properties.has_key?(key)
        @_properties[key]
      else
        @_properties[key] = (!new_record? && __java_obj.has_property?(key)) ? read_property_from_db(key) : attribute_defaults[key]
      end
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

          attribute_defaults[prop.to_s] = options[:default]  if options.has_key?(:default)

          _props[prop][:converter] ||= Oriented::TypeConverters.converter(_props[prop][:type])

          create_property_methods(prop)
        end

      end

      def create_property_methods(name)
        define_method "#{name}" do
          send(:[], name)
        end

        define_method "#{name}=" do |val|
          send(:[]=, name, val)
        end
        
      end

      def _converter(pname)
        prop = _props[pname]
        (prop && prop[:converter]) || Oriented::TypeConverters::DefaultConverter
      end
    end
    
    # Write attributes to the Neo4j DB only if they're altered
    def write_changed_attributes
      @_properties.each do |attribute, value|
          write_property_to_db(attribute, value)
      end
    end    
    
    def write_all_attributes
      mergeprops = self.class.attribute_defaults.merge(self.props||{})      
      mergeprops.each do |attribute, value|
        write_property_to_db(attribute, value)
      end      
    end

    def write_default_values
      self.class.attribute_defaults.each_pair do |attr, val| 
        self.send("#{attr}=", val)
      end
    end
  end
end
