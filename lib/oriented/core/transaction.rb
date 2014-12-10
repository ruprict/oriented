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
    
    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::LOADED           = 0;
    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::UPDATED          = 1;
    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::DELETED          = 2;
    # public static final byte  Java::ComOrientechnologiesOrientCoreDbRecord::ORecordOperation::CREATED          = 3;
    
    LOADED = 0
    UPDATED = 1 << 1
    DELETED = 1 << 2
    CREATED = 1 << 3
    
    TRANSACTION_TYPES = {0 => LOADED, 1 => UPDATED, 2 => DELETED, 3 => CREATED} unless defined?(TRANSACTION_TYPES)
        

    
    class Transaction

      def self.run connection = Oriented.connection, options={}, &block
        puts options.inspect if options[:commit_on_sucess]
        ensure_connection(connection)
        ret = yield
        @transaction_type = 0
        Oriented.graph.raw_graph.transaction.current_record_entries.to_a.each do |r|
          @transaction_type |= TRANSACTION_TYPES[r.type]
        end        
        connection.commit if options.fetch(:commit_on_success, false) == true
        @retries = 0 # RESET to 0 if it's able ot commit
        ret
      rescue Java::ComOrientechnologiesOrientCoreException::OConcurrentModificationException => ex
        puts "RESCUE #{ex.inspect}"
        @retries ||= 0
        if @retries < 1 && (@transaction_type & (DELETED | CREATED)) == 0
          @retries += 1
          retry
        else
          unless connection.java_connection.closed?
            connection.rollback
          end
          raise ex
        end
      rescue => ex
        unless connection.java_connection.closed?
          connection.rollback
        end
        raise ex
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
          send(:define_method, "#{method}!") do |*args|            
            Oriented::Core::Transaction.run(Oriented.connection, {commit_on_success: true}) { send(tx_method, *args) }
          end
        end
      end
    end
  end

end
