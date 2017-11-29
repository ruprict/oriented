module Oriented
  module Core
    # Can be used to define your own wrapper class around nodes and relationships
    module Vertex
    
      def id
        get_id.to_s
      end

      def get_rid
        get_id.to_s
      end
      
      def delete
        remove
      end
      
      def loaded?
        !!(record.internal_status.name == "LOADED")
      end
      
      def load
        if !loaded?
          record.load(record.rid)                  
        end
      end
      
      
    end
  end
end
