require 'oriented'
class Model
  include Oriented::Vertex

  field :name

  has_many(:stylists)
  has_one(:drug_dealer)
end

class DrugDealer
  include Oriented::Vertex
  field :name
  field :product
end

class Stylist
  include Oriented::Vertex
  field :name

  has_many(:pieces_of_gossip)
end
