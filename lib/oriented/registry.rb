require 'ostruct'

module Oriented
  class Registry
    def self.define(&block)
      @@instance = self.new(&block)
    end

    def self.data_class_for(model_class)
      @@instance.data_class_for(model_class)
    end

    def self.model_class_for(data_class)
      @@instance.model_class_for(data_class)
    end

    def initialize(&block)
      @data_to_model_map = {}
      @model_to_data_map = {}
      self.instance_eval &block
    end

    # the mapping is done by the class names, to avoid
    # class-reloading issues in Rails dev mode
    def map model_class, data_class
      @model_to_data_map[model_class.to_s] = data_class.to_s
      @data_to_model_map[data_class.to_s] = model_class.to_s
    end

    def data_class_for model_class
      data_class = @model_to_data_map[model_class.to_s]
      return model_class unless data_class

      data_class
    end

    def model_class_for data_class
      model_class = @data_to_model_map[data_class.to_s]
      return data_class unless model_class

      model_class
    end

    private

    def model_to_data_map
      @model_to_data_map
    end

    def data_to_model_map
      @data_to_model_map
    end
  end
end
