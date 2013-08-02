require 'oriented'
class Model
  include Oriented::Vertex

  property :name

  has_n(:stylists)
  has_one(:drug_dealer)
end

class DrugDealer
  include Oriented::Vertex
  property :name
  property :product
end

class Stylist
  include Oriented::Vertex
  property :name

  has_n(:pieces_of_gossip)
end
