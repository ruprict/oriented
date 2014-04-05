# Oriented

Oriented attempts to wrap access to OrientDB in an ORM-like manner. 

The conception of this gem started with a lot of copying/pasting of
code from the wonderful Neo4j gems. Oriented only provides a 
fraction of what the Neo4j gems currently offer.

## Installation

Add this line to your application's Gemfile:

    gem 'oriented'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oriented

## Usage

Oriented can be included in your models by simple extending the 
model with the appropriate module, based on whether your OrientDB
class is a Vertex or an Edge

    require 'oriented'

    class Person
      include Oriented::Vertex
      property name

      has_n(:knows).relationshp(Knows)
    end

    class Knows
      include Oriented::Edge
    end

    fred = Person.new(name: 'Fred')

    barney = Person.new(name: 'Barney')

    fred.knows << barney



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write code and tests.  (Please write tests.) 
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
