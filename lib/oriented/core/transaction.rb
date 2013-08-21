module Oriented
  module Core
    class Transaction

      def self.run connection = Oriented.connection, &block
        begin 
          ensure_connection(connection)
          ret = yield
          connection.commit
          ret
        rescue => ex
          connection.rollback
        ensure
          connection.close
        end
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
