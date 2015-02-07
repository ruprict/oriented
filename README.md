# Oriented

[![Code Climate](https://codeclimate.com/github/ruprict/oriented/badges/gpa.svg)](https://codeclimate.com/github/ruprict/oriented)
[![Test Coverage](https://codeclimate.com/github/ruprict/oriented/badges/coverage.svg)](https://codeclimate.com/github/ruprict/oriented)

[ ![Codeship Status for ruprict/oriented](https://codeship.com/projects/61212180-41ed-0132-0f27-6ee7d852ff61/status?branch=master)](https://codeship.com/projects/44312)


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
class is a Vertex or an Edge.

If, for example, you had these models:

    require 'oriented'

    class Person
      include Oriented::Vertex

      property :name

      has_n(:knows).relationship(Knows)
    end

    class Knows
      include Oriented::Edge

      property :rel_type, default: 'friend'
    end

then, you might do something like this:

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
    ==> Fred know ['Barney'] as a ['friend']

### Querying

Oriented supports basic `#get!` methods:

    fred = Person.get!(name: 'Fred')

Beyond that, right now, you'll have to leverage OrientDB, using either Gremlin or raw OrientDB SQL.

As a tip, don't use gremilin unless you have a small dataset.  In most cases, it will load hugh amounts of the graph into memory, which can be slow. 

OrientDB has a relatively robust SQL-ish query language that offloads most of the work to the server. Use `OrientDB::SQLCommand`

(should probably put some examples here)

## Roadmap
* Move to 2.0 when it is released
* Need docs around configuration
* Should probably look into a decent query DSL
    * Thinking of starting with Arel

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write code and tests.  (Please write tests.) 
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

# License
Oriented uses the MIT License. See LICENSE.txt for details.
