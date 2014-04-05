require 'oriented'

class Knows
  include Oriented::Edge

  property :rel_type, default: 'friend'
end
