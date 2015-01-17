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
      # Java::ComOrientechnologiesOrientCoreConfig::OGlobalConfiguration::CACHE_LOCAL_ENABLED.setValue(Oriented.configuration.enable_local_cache||false)
      # Java::ComOrientechnologiesOrientCoreConfig::OGlobalConfiguration::CACHE_LEVEL2_ENABLED.setValue(Oriented.configuration.enable_level2_cache||false)            
      Java::ComOrientechnologiesOrientCoreConfig::OGlobalConfiguration::NETWORK_BINARY_DNS_LOADBALANCING_ENABLED.setValue(Oriented.configuration.network_binary_dns_loadbalancing_enabled);
      
      @url = options.fetch(:url, ENV["ORIENTDB_URL"] || Oriented.configuration.url)
      @pooled = Oriented.configuration.pooled || false
      @min_pool = Oriented.configuration.min_pool || 5
      @max_pool = Oriented.configuration.max_pool || 100
      @user = options.fetch(:username, ENV["ORIENTDB_DB_USER"] || Oriented.configuration.username || "admin")
      @pass = options.fetch(:password, ENV["ORIENTDB_DB_PASSWORD"] || Oriented.configuration.password || "admin")

      @factory = OrientDB::BLUEPRINTS.impls.orient.OrientGraphFactory.new(@url, @user, @pass).setupPool(@min_pool, @max_pool)
    end

    def connection
      g = @factory.getTx();
      if g.closed?
        @resetpool = true
        self.connection()
      else
        @retries = 0
        return g
      end
    rescue => e
      if @resetpool
        @factory.close()
        @factory.setupPool(@min_pool, @max_pool)
        @resetpool = false
      end
      @retries ||= 0
      if @retries < 1
        @retries += 1
        retry
      else
        raise e
      end
    end

  end

  class Connection
    attr_accessor :java_connection, :graph, :connection_factory, :pooled, :user, :url, :max_retries

    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::LOADED           = 0;
    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::UPDATED          = 1;
    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::DELETED          = 2;
    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::CREATED          = 3;
    LOADED = 0
    UPDATED = 1 << 1
    DELETED = 1 << 2
    CREATED = 1 << 3

    TRANSACTION_TYPES = {0 => LOADED, 1 => UPDATED, 2 => DELETED, 3 => CREATED} unless defined?(TRANSACTION_TYPES)

    def connect
      @max_retries ||= 1
      unless @graph
        @graph = ConnectionFactory.instance.connection
        @java_connection = @graph.raw_graph
        if Oriented.configuration.use_identity_map
          Oriented::IdentityMap.enable
          register_db_listener(Oriented::Listener)
        end
      end
    end

    # This is probably temporary.  I saw in the master branch of Orientdb they updated the database to inherit from listenerManager
    # which will allow us to browser all the listeners on the db instance just like you can with hooks.
    # But as of 2.0-M2 you can't get the listeners.
    def db_listeners
      Thread.current[:db_listener] ||= Set.new
    end

    def register_db_listener(listener_class)
      return db_listeners if db_listeners.classify{|l| l.class }.include?(listener_class)
      return unless @java_connection

      listener = listener_class.new
      db_listeners << listener
      @java_connection.registerListener(listener)
    end

    def unregister_db_listeners
      db_listeners.each do |l|
       @java_connection.unregisterListener(l)
      end
    end

    def close(force = false)
      if @graph
        @graph.shutdown
        @java_connection = nil        
        @graph=nil
      end
    end

    def rollback
      @graph.rollback
    end

    def commit
      @transaction_type = 0
      Oriented.graph.raw_graph.transaction.current_record_entries.to_a.each do |r|
        @transaction_type |= TRANSACTION_TYPES[r.type]
      end
      graph.commit
      Oriented::IdentityMap.clear
      @retries = 0
    rescue Java::ComOrientechnologiesOrientCoreException::OConcurrentModificationException => ex
      @retries ||= 0
      if @retries < max_retries && (@transaction_type & DELETED) == 0
        increment_retry
        puts "rescue att 1 e = #{ex}"
        Oriented::IdentityMap.all.each do |k, v|
          v.save
        end
        retry
      else
        unless java_connection.closed?
          rollback
        end
        raise ex
      end
    rescue => ex
      unless java_connection.closed?
        rollback
      end
      raise ex
    ensure

    end

    def increment_retry
      @retries = @retries + 1
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

    # def acquire_java_connection
    #   jdb = if @pooled
    #           Java::ComOrientechnologiesOrientCoreDbDocument::ODatabaseDocumentPool.global(@min_pool, @max_pool).acquire(@url, @user, @pass);
    #         else
    #           db = OrientDB::GraphDatabase.new(@url)
    #           db.open(@user, @pass)
    #           db
    #         end
    #   Oriented.hook_classes.each {|h| jdb.register_hook(h.new)}
    #   jdb
    # end

  end
end
