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
    attr_accessor :min_pool, :max_pool, :enable_local_cache, :network_binary_dns_loadbalancing_enabled, :use_identity_map

    def initialize
      # defaults
      # If true, this will create a pooled connection
      @pooled = false
      @min_pool = 1
      @max_pool = 5
      @enable_local_cache = false
      @network_binary_dns_loadbalancing_enabled = false
      @use_identity_map = true
    end

    def clear
      @enable_local_cache = false      
      @pooled = false
      @url = nil
      @password = nil
      @username = nil
      @min_pool = 1
      @max_pool = 5
      @network_binary_dns_loadbalancing_enabled = false
      @use_identity_map = true
    end

    def to_s
      "Oriented Configuration: url=#{@url}" 
    end
  end
end
