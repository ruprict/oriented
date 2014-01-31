module Oriented
  class << self
    
    def connection
      connection = Thread.current[:orient_db] || Connection.new
      Thread.current[:orient_db] = connection
      connection.connect
      connection
    end

    def graph(stop_transaction = false)
      connection 
      connection.java_connection.transaction.close if stop_transaction
      connection.graph
    end

    def close_connection(force=false)
      if conn = Thread.current[:orient_db]
        conn.close(force)
        Thread.current[:orient_db] = nil
      end
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

  class Connection
    attr_accessor :java_connection, :graph, :connection_factory, :pooled

    def initialize(options={})
      # Java::ComOrientechnologiesOrientCoreConfig::OGlobalConfiguration::USE_WAL.setValue(false)            
      @url = options.fetch(:url, ENV["ORIENTDB_URL"] || Oriented.configuration.url)
      @pooled = Oriented.configuration.pooled || false
      @user = options.fetch(:username, ENV["ORIENTDB_DB_USER"] || Oriented.configuration.username || "admin")
      @pass = options.fetch(:password, ENV["ORIENTDB_DB_PASSWORD"] || Oriented.configuration.password || "admin")
    end

    def connect
      if (!@java_connection || @java_connection.closed?)
        @java_connection = acquire_java_connection
        @graph = OrientDB::OrientGraph.new(@java_connection)
      else
        
      end
      # @java_connection = (@java_connection && !@java_connection.closed?) ? @java_connection : acquire_java_connection
      # @graph = OrientDB::OrientGraph.new(@java_connection)
      self
    end

    def close(force = false)
      if @pooled && @java_connection
        if force
          puts "** Yes, I got in here to force close"
          puts Java::ComOrientechnologiesOrientCoreDbGraph::OGraphDatabasePool.global().pools.inspect
          @java_connection.force_close()
          @graph = nil
        else
          @java_connection.close 
        end
      end
      @graph.shutdown if @graph
      @java_connection = nil
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


    private

    def acquire_java_connection
      jdb = if @pooled
              Java::ComOrientechnologiesOrientCoreDbDocument::ODatabaseDocumentPool.global().acquire(@url, @user, @pass);
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
