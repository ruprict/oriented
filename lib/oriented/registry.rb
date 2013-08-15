require 'ostruct'

module Oriented
  class Registry
    def self.define(&block)
      @@instance = self.new(&block)
    end

    def self.odb_class_for(ruby_class)
      instance.odb_class_for(ruby_class)
    end

    def self.ruby_class_for(odb_class)
      instance.ruby_class_for(odb_class)
    end

    def initialize(&block)
      self.instance_eval &block if block_given?
    end

    # the mapping is done by the class names, to avoid
    # class-reloading issues in Rails dev mode
    def map ruby_class, odb_class
      ruby_to_odb_map[ruby_class.to_s] = odb_class.to_s
      odb_to_ruby_map[odb_class.to_s] = ruby_class.to_s
    end

    def odb_class_for ruby_class
      odb_class = ruby_to_odb_map[ruby_class.to_s]
      odb_class ||  ruby_class.to_s
    end

    def ruby_class_for odb_class
      ruby_class = odb_to_ruby_map[odb_class.to_s]
      ruby_class || odb_class.to_s
    end

    private

    def ruby_to_odb_map
      @ruby_to_odb_map ||= {}
    end

    def odb_to_ruby_map
      @odb_to_ruby_map ||= {}
    end

    def self.instance
      @@instance ||= self.new
    end
  end
end
