require "oriented/version"

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
require "oriented/relationship/rel_type"
require "oriented/relationship/rel_instance"
require "oriented/relationships"

require "oriented/type_converters"
require "oriented/class_name"
require "oriented/properties"

# Vertex
require "oriented/vertex/delegates"
require "oriented/vertex"

# Edge
require "oriented/edge/delegates"
require "oriented/edge"

module Oriented
  # Your code goes here...
end
