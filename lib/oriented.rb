require "oriented/version"
require "oriented/registry"

require 'oriented/configuration'
require 'oriented/connection'

# Core Java Object
require "orientdb"
require "oriented/core/core"

# Persistence
require "oriented/persistence"

# Relationships
require "oriented/wrapper/class_methods"
require "oriented/wrapper"
require "oriented/relationships/rel_type"
require "oriented/relationships/vertex_instance"
require "oriented/relationships/edges_instance"
require "oriented/relationships"

require "oriented/type_converters"
require "oriented/class_name"
require "oriented/properties"

# Vertex
require "oriented/vertex/delegates"
require "oriented/vertex/vertex_methods"
require "oriented/vertex_persistence"
require "oriented/vertex"

# Edge
require "oriented/edge/delegates"
require "oriented/edge/edge_methods"
require "oriented/edge_persistence"
require "oriented/edge"
require "oriented/edge/base_edge"

require "oriented/base_hook"

module Oriented
  # Your code goes here...
end
