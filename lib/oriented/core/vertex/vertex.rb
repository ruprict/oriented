module Oriented
  module Core
    # Can be used to define your own wrapper class around nodes and relationships
    module Vertex
    
      def get_rid
        get_id.to_s
      end
      
      def delete
        remove
      end
      
    end
  end
end
