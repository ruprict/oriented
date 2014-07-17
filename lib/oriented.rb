require 'orientdb'

require 'forwardable'

require_relative "oriented/version"
require_relative "oriented/registry"

require_relative 'oriented/configuration'
require_relative 'oriented/connection'
require_relative "oriented/identity_map"

# Core Java Object
require_relative "oriented/core/core"

# Persistence
require_relative "oriented/persistence"

# Relationships
require_relative "oriented/wrapper/class_methods"
require_relative "oriented/wrapper"
require_relative "oriented/relationships/rel_type"
require_relative "oriented/relationships/vertex_instance"
require_relative "oriented/relationships/edges_instance"
require_relative "oriented/relationships"

require_relative "oriented/type_converters"
require_relative "oriented/class_name"
require_relative "oriented/properties"

# Vertex
require_relative "oriented/vertex/delegates"
require_relative "oriented/vertex/vertex_methods"
require_relative "oriented/vertex_persistence"
require_relative "oriented/vertex"

# Edge
require_relative "oriented/edge/delegates"
require_relative "oriented/edge/edge_methods"
require_relative "oriented/edge_persistence"
require_relative "oriented/edge"
require_relative "oriented/edge/base_edge"

require_relative "oriented/base_hook"

module Oriented
  # Your code goes here...
end
