module Oriented
  module Relationships
    class VertexInstance
      include Enumerable
      extend Oriented::Core::TransactionWrapper

      def initialize(vertex, rel_type)
        @vertex = vertex
        @rel_type = rel_type        
        @rel_class = Oriented::BaseEdge
        clname = Oriented::Registry.ruby_class_for(rel_type.label)
        if clname
          clname = clname[0].upcase + clname[1..-1]
          
          @rel_class = to_class(clname) if (Kernel.const_defined?(clname) || Object.const_defined?(clname))

          # begin
          #   @rel_class = to_class(clname) #if (Kernel.const_defined?(clname) || Object.const_defined?(clname))
          # rescue Exception=>e
          #   # Rails.logger.info("Exception = #{e.inspect}")
          #   puts "Exception = #{e.inspect}"
          # end
                    
        end

        @rels = []
        @unpersisted_rels = []        
        
      end  
      
      def to_class(class_name)
        class_name.split("::").inject(Kernel) { |container, name| container.const_get(name.to_s) }
      end

      # def each_node(dir, &block)
      #   relationships(dir).each do |rel|
      #     if rel.start_node == @node
      #       block.call rel.end_node
      #     else
      #       block.call rel.start_node
      #     end
      #   end
      #   if @node.persisted?
      #     cache_persisted_nodes_and_relationships(dir) if @persisted_related_nodes[dir].nil?
      #     @persisted_related_nodes[dir].each {|node| block.call node unless relationship_deleted?(dir,node)}
      #   end
      # end
      
      def each
        relationships().each do |r|
          yield r.other_vertex(@vertex)
          # yield self.class.wrap(v)
        end
      end
      
      def create(node_attr = {}, rels_attrs = {})
        objcls = @rel_type.target_class || Oriented::Core::JavaVertex
        v = objcls.create(node_attr)
        rel = self.create_relationship_to(v, rels_attrs)
        v
      end
      wrap_in_transaction :create
      
      def empty?
        return !other_vertex if @rel_type.cardinality == :one
        first == nil
      end

      def other_vertex
        # return unless @rel_type.cardinality == :one
        rel = relationships().first
        rel.other_vertex(@vertex) if rel
      end
      
      def <<(other)
        return if @rel_type.cardinality == :one
        create_relationship_to(other)
        other
      end
      
      def connect(other, attrs={})
        return if @rel_type.cardinality == :one
        create_relationship_to(other, attrs)
        other  
      end

      def create_relationship_to(other, attrs={})        
        return self if !other
        sv = @vertex
        ev = other
        if @rel_type.direction == Oriented::Relationships::Direction::IN
          sv = other
          ev = @vertex
        end
        edge = @rel_class.new(sv, ev, @rel_type.label.to_s, attrs)

        edge

      end
      wrap_in_transaction :create_relationship_to

      def destroy_relationship
        relationships().each {|e| 
          javaobj = (e.respond_to?(:__java_obj) ? e.__java_obj : e)
          if javaobj
            other =  e.other_vertex(@vertex)
            javaobj.remove  
            rm_rel(e)          
            vertex.save()
            other.save()            
          else
            rm_unpersisted_rel(e)
          end
        }
      end
      wrap_in_transaction :destroy_relationship
      
      def destroy_relationship_to(other)
        relationships().each do |e| 
          javaobj = (e.respond_to?(:__java_obj) ? e.__java_obj : e)
          if javaobj
            if e.start_vertex.id == other.id || e.end_vertex.id == other.id
              javaobj.remove  if javaobj
              rm_rel(e)          
              vertex.save()
              other.save()            
            end
          elsif e.start_vertex == other || e.end_vertex == other
            rm_unpersisted_rel(e)
          end
                    

            # e.remove
            # vertex.save()
            # other.__java_obj.save()            
            # vertex.record.reload
            # other.record.reload

        end
      end
      wrap_in_transaction :destroy_relationship_to


      def destroy_all(only_unpersisted=false)
        relationships().each do |e|
          rm_unpersisted_rel(e)
          javaobj = (e.respond_to?(:__java_obj) ? e.__java_obj : e)
          
          if !only_unpersisted && javaobj
            other =  e.other_vertex(@vertex)            
            rm_rel(e)                
            javaobj.remove        
            vertex.save()
            other.save()
          end      
        end

      end


      # private

      def vertex_query
        vertex.query().labels(@rel_type.label).vertices()
      end

      def edge_query
        vertex.get_edges(@rel_type.direction, @rel_type.label)
        # vertex.query().labels(@rel_type.label).edges()
      end

      def vertex
        @vertex.__java_obj.load
        @vertex.__java_obj
      end

      def check_edge_type(rel_label)
        exists = vertex.graph.get_edge_type(rel_label.to_s)
        unless exists
          vertex.graph.create_edge_type(rel_label.to_s)
        end
      end
      
      def relationships()
          if @vertex.persisted?
            @unpersisted_rels + edge_query.to_a
          else 
            @unpersisted_rels
          end
      end
      
      def add_rel(rel)
        @rels << rel
      end 
      
      def add_unpersisted_rel(rel)
        @unpersisted_rels << rel      
      end
      
      def rm_rel(rel)
        @rels.delete(rel)
      end 
      
      def rm_unpersisted_rel(rel)
        @unpersisted_rels.delete(rel)
      end
      
      
      def persisted?
        @unpersisted_rels.empty?
      end
      
       def persist
          rels = @unpersisted_rels.clone
          @unpersisted_rels.clear
          rels.each do |rel|
            # Rails.logger.info("rel = #{rel.inspect} rel persisted = #{rel.persisted?} or relcoru = #{rel.create_or_updating?}")
            success = rel.persisted? || rel.create_or_updating? || rel.save
            add_rel(rel)
            # don't think this can happen - just in case, TODO
            raise "Can't save  #{rel}, validation errors " unless success
          end

        end
        
        
      
    end
  end
end
