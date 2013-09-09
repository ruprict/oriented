require 'active_support/concern'

module Oriented
    module Persistence
      
      extend ActiveSupport::Concern
      extend Oriented::Core::TransactionWrapper


      # Persist the object to the database.  Validations and Callbacks are included
      # by default but validation can be disabled by passing <tt>:validate => false</tt>
      # to <tt>save</tt>. Creates a new transaction.
      # @param (see Neo4j::Rails::Validations#save)
      # @return [Boolean] true if it was persisted
      # @see Neo4j::Rails::Validations Neo4j::Rails::Validations - for the :validate parameter
      # @see Neo4j::Rails::Callbacks Neo4j::Rails::Callbacks - for callbacks
      def save(*)
        create_or_update
        # __java_obj.save
      end
      wrap_in_transaction :save

      # Persist the object to the database.  Validations and Callbacks are included
      # by default but validation can be disabled by passing :validate => false
      # to #save!  Creates a new transaction.
      #
      # @raise a RecordInvalidError if there is a problem during save.
      # @param (see Neo4j::Rails::Validations#save)
      # @return nil
      # @see #save
      # @see Neo4j::Rails::Validations Neo4j::Rails::Validations - for the :validate parameter
      # @see Neo4j::Rails::Callbacks Neo4j::Rails::Callbacks - for callbacks
      def save!(*args)
        save
        # unless save(*args)
        #   raise RecordInvalidError.new(self)
        # end
      end

      # Removes the node from Neo4j and freezes the object.
      def destroy
        delete
        # freeze
      end

      # Same as #destroy but doesn't run destroy callbacks and doesn't freeze
      # the object. Creates a new transaction
      def delete
        __java_obj.remove unless new_record? || destroyed?
        set_deleted_properties
        # __java_obj.record.reload if __java_obj
      end
      wrap_in_transaction :delete

      # Returns +true+ if the object was destroyed.
      def destroyed?
        @_deleted || (!new_record? && !self.class.load_entity(_orient_id))
      end

      # Returns +true+ if the record is persisted, i.e. it’s not a new record and it was not destroyed
      def persisted?
        !new_record? && !destroyed?
      end

      # Returns +true+ if the record hasn't been saved to Neo4j yet.
      def new_record?
        __java_obj.nil?
      end

      alias :new? :new_record?

      # Freeze the properties hash.
      def freeze
        @_properties.freeze
        self
      end

      # Returns +true+ if the properties hash has been frozen.
      def frozen?
        freeze_if_deleted
        @_properties.frozen?
      end

      module ClassMethods
        class << self
          include Oriented::Core::TransactionWrapper
        end

        def transaction(&block)
          # Neo4j::Rails::Transaction.run do |tx|
          #   block.call(tx)
          # end
        end

        def new(*args, &block)
          instance = orig_new(*args, &block)
          # instance = super(*args, &block)          
          instance.instance_eval(&block) if block
          instance
        end

        def get!(rid)          
          if rid.kind_of?(Hash)
            if rid.count > 1
              
            else
              clname = Oriented::Registry.odb_class_for(self.name.to_s)
              rr = rid.flatten
              key = clname+"."+rr[0].to_s.split(".").last
              val = rr[1].to_s
              vertex = Oriented.graph.get_vertices(key, val).first              
            end
            
          else
            vertex = Oriented.graph.get_vertex(rid)            
          end

          return nil unless vertex
          m = orig_new
          m.__java_obj = vertex
          m
        end
        
        # Initialize a model and set a bunch of attributes at the same time.  Returns
        # the object whether saved successfully or not.
        def create(*args)
          new(*args).tap do |o|
            yield o if block_given?
            o.save
          end
        end

        # Get the indexed entity, creating it (exactly once) if no indexed entity exist.
        #
        # @example Creating a Unique node
        #
        #   class MyNode < Neo4j::Rails::Model
        #     property :email, :index => :exact, :unique => true
        #   end
        #
        #   node = MyNode.get_or_create(:email =>'jimmy@gmail.com', :name => 'jimmy')
        #
        # @see #put_if_absent
        def get_or_create(*args)
          props = args.first

          props.keys.each do |key|
            props[key.to_s] = props.delete(key)
          end

          idx = self.oclass.indexes.first
          
          vtx = Oriented.connection.graph.get_vertices(idx.name, props[idx.definition.fields[0]]).to_a if idx && props[idx.definition.fields[0]]
          if vtx && vtx.first
            return vtx.first.wrapper
          else
            obj = self.new(props).wrapper
            obj.save
            return obj
          end
          # raise "Can't get or create entity since #{props.inspect} does not included unique key #{props[unique_factory_key]}'" unless props[unique_factory_key]
          # index = index_for_type(_decl_props[unique_factory_key][:index])
          # Neo4j::Core::Index::UniqueFactory.new(unique_factory_key, index) { |*| create!(*args) }.get_or_create(unique_factory_key, props[unique_factory_key]).wrapper
        end
        wrap_in_transaction :get_or_create

        # Same as #create, but raises an error if there is a problem during save.
        # @return [Neo4j::Rails::Model, Neo4j::Rails::Relationship]
        def create!(*args)
          new(*args).tap do |o|
            yield o if block_given?
            o.save!
          end
        end

        # Destroy each node in turn.  Runs the destroy callbacks for each node.
        def destroy_all
          all.each do |n|
            n.destroy
          end
        end
      end

      # Returns if the entity is currently being updated or created
      def create_or_updating?
        !!@_create_or_updating
      end


      def update_attributes(attrs)
        attrs.each_pair do |k,v|
          self.public_send("#{k}=", v)
        end
      end

      protected

      def update
        write_changed_attributes
        true
      end

      def create_or_update
        # since the same model can be created or updated twice from a relationship we have to have this guard
        @_create_or_updating = true
              result = persisted? ? update : create
              unless result != false
                # Neo4j::Rails::Transaction.fail if Neo4j::Rails::Transaction.running?
                false
              else
                true
              end
            rescue => e
              # Neo4j::Rails::Transaction.fail if Neo4j::Rails::Transaction.running?
              raise e
            ensure
              @_create_or_updating = nil
      end

      def set_deleted_properties
        @_deleted = true
      end

      public
      class RecordInvalidError < RuntimeError
        attr_reader :record

        def initialize(record)
          @record = record
          super
          # super(@record.errors.full_messages.join(", "))
        end
      end
    end
end

