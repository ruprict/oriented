module Oriented

  class << self

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure 
    yield(configuration) 
  end

  class Configuration
    attr_accessor :pooled, :url, :username, :password
    attr_accessor :min_pool, :max_pool

    def initialize
      # defaults
      # If true, this will create a pooled connection
      @pooled = false
      @min_pool = 1
      @max_pool = 5
    end

    def clear
      @pooled = false
      @url = nil
      @password = nil
      @username = nil
      @min_pool = 1
      @max_pool = 5
    end
  end
end
