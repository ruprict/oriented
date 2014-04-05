require_relative 'example/knows'
require_relative 'example/person'

$odb = OrientDB::GraphDatabase.new("memory:example-db").create
$odb.close

Oriented.configure do |config|

 config.url = "memory:example-db" 

end

fred = Person.new(name: 'Fred')
fred.save

barney = Person.new(name: 'Barney')
barney.save

fred.knows << barney
fred.save

puts "Fred knows:  #{ fred.knows.to_a.map(&:name) } as a #{fred.knows_rels.to_a.map(&:rel_type)}"
