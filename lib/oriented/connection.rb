module Oriented
  class << self
    
    def connection
      @connection ||= Connection.new   
      @connection.connect
      @connection
    end

    def graph
      connection.graph
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
      @java_connection = acquire_java_connection
      @graph = OrientDB::OrientGraph.new(@java_connection)
    end

    def close
      @java_connection.close if @java_connection
      @graph.close if @graph
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
