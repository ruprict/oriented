require 'rspec'
require_relative '../lib/oriented'
require 'orientdb'
require_relative 'db'

Dir['./support/**/*.rb'].sort.each {|f| require f}

RSpec.configure do |config|

end
