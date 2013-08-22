require 'rspec'
require_relative '../lib/oriented'
require 'orientdb'

Dir['./spec/support/**/*.rb'].sort.each {|f| require f}

RSpec.configure do |config|
  config.before(:each) do
  end

end
