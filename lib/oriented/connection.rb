require 'singleton'
module Oriented
  class << self
    def connection
      @connection ||= Connection.new
      @connection.connect
      @connection
    end

    def graph(stop_transaction = false)
      connection.graph
    end

    def close_connection(force=false)
      @connection.close if @connection
      @connection =nil
    end

    def register_hook_class(hook_class)
      return hook_classes if hook_classes.include?(hook_class)
      hook_classes << hook_class
      return unless connection.java_connection

      current_hooks = connection.java_connection.hooks.to_a.select {|h| h.instance_of?(hook_class)}
      if current_hooks.empty?
        connection.java_connection.register_hook(hook_class.new) 
        connection.connect
      end

    end

    def unregister_hook_class(hook_class)
      return hook_classes unless hook_classes.include?(hook_class)
      hook_classes.delete(hook_class)
      return unless connection.java_connection

      hookies = connection.java_connection.hooks.to_a
      hookies.each {|h| 
        if h.instance_of?(hook_class) 
          connection.java_connection.unregister_hook(h)
        end
      }
    end

    def hook_classes
      @hook_classes ||= Set.new
    end

  end

  class ConnectionFactory
    include Singleton

    def initialize(options={})
      puts "** initializng ORIENTDB ConnectionFactory"
      Java::ComOrientechnologiesOrientCoreConfig::OGlobalConfiguration::CACHE_LEVEL1_ENABLED.setValue(Oriented.configuration.enable_level1_cache||false)
      Java::ComOrientechnologiesOrientCoreConfig::OGlobalConfiguration::CACHE_LEVEL2_ENABLED.setValue(Oriented.configuration.enable_level2_cache||false)            

      @url = options.fetch(:url, ENV["ORIENTDB_URL"] || Oriented.configuration.url)
      @pooled = Oriented.configuration.pooled || false
      @min_pool = Oriented.configuration.min_pool || 5
      @max_pool = Oriented.configuration.max_pool || 100
      @user = options.fetch(:username, ENV["ORIENTDB_DB_USER"] || Oriented.configuration.username || "admin")
      @pass = options.fetch(:password, ENV["ORIENTDB_DB_PASSWORD"] || Oriented.configuration.password || "admin")
      @factory = OrientDB::BLUEPRINTS.impls.orient.OrientGraphFactory.new(@url, @user, @pass).setupPool(@min_pool, @max_pool)
    end

    def connection
      @factory.getTx();
    end
  end

  class Connection
    attr_accessor :java_connection, :graph, :connection_factory, :pooled, :user, :url

    def connect
      unless @graph
        @graph = ConnectionFactory.instance.connection
        @java_connection = @graph.raw_graph
      end
    end

    def close(force = false)
      if @graph
        @graph.shutdown
        @java_connection.close if @java_connection
        @graph=nil
      end
    end

    def rollback
      @graph.rollback
    end

    def commit
      @graph.commit
    end

    def transaction_active?
      @java_connection.transaction.active?
    end

    def to_s
      "Oriented Connection: url=#{@url}" 
    end

    def available_connections
      Java::ComOrientechnologiesOrientCoreDbDocument::ODatabaseDocumentPool.global().getAvailableConnections(url, @user)
    end

    private

    def acquire_java_connection
      jdb = if @pooled
              Java::ComOrientechnologiesOrientCoreDbDocument::ODatabaseDocumentPool.global(@min_pool, @max_pool).acquire(@url, @user, @pass);
            else
              db = OrientDB::GraphDatabase.new(@url)
              db.open(@user, @pass)
              db
            end
      Oriented.hook_classes.each {|h| jdb.register_hook(h.new)}
      jdb
    end

  end
end
