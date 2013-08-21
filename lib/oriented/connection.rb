module Oriented
  class << self
    
    def connection
      @connection ||= Connection.new   
      @connection.connect
      @connection
    end

    def graph(stop_transaction = false)
      connection 
      @connection.java_connection.transaction.close if stop_transaction
      @connection.graph
    end
  end

  class Connection
    attr_accessor :java_connection, :graph, :connection_factory

    def initialize
      @url = ENV["ORIENTDB_URL"] || Oriented.configuration.url
      @pooled = Oriented.configuration.pooled || false
      @user = ENV["ORIENTDB_USER"] || Oriented.configuration.username || "admin"
      @pass = ENV["ORIENTDB_PASSWORD"] || Oriented.configuration.password || "admin"
    end

    def connect
      @java_connection ||= acquire_java_connection
      @graph = OrientDB::OrientGraph.new(@java_connection)
    end

    def close
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
        Java::ComOrientechnologiesOrientCoreDbGraph::OGraphDatabasePool.global().acquire(@url, @user, @pass);
      else
        db = OrientDB::GraphDatabase.new(@url)
        db.open(@user, @pass)
        db
      end
    end

  end
end
