class Person
  include Oriented::Vertex

  property :name

  has_n(:knows).relationship(Knows)
end
