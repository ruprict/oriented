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

    def initialize
      # defaults
      # If true, this will create a pooled connection
      @pooled = false
    end

    def clear
      @pooled = false
      @url = nil
      @password = nil
      @username = nil
    end
  end
end
