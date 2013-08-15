module Oriented

  class << self
    attr_accessor :configuration
  end

  def self.configure 
    self.configuration ||= Configuration.new
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
