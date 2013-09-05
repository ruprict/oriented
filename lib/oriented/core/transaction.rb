module Oriented
  module Core
    #
    # Class to encapsulate the transaction for OrientDB
    #
    # Currently, if anything fails, it will rollback the connection
    # and then CLOSE it. This means any existing objects in your
    # context will be hosed and you'll have to go get them from the db
    # with a new connection.
    #
    # An Identity map would help this, methinks.
    class Transaction

      def self.run connection = Oriented.connection, &block
        ensure_connection(connection)
        ret = yield
        connection.commit
        ret
      rescue => ex
        connection.rollback
        connection.close(true)
        raise 
      ensure
      end

      private
      def self.ensure_connection(conn)
        unless conn.transaction_active?
          conn.connect
        end
      end
    end

    module TransactionWrapper
      def wrap_in_transaction(*methods)
        methods.each do |method|
          tx_method = "#{method}_no_tx"
          send(:alias_method, tx_method, method)
          send(:define_method, method) do |*args|            
            Oriented::Core::Transaction.run { send(tx_method, *args) }
          end
        end
      end
    end
  end

end
