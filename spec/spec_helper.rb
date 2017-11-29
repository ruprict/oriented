require 'rspec'
require_relative '../lib/oriented'
require 'orientdb'
require 'active_support'

Dir['./spec/support/**/*.rb'].sort.each {|f| require f}

RSpec.configure do |config|
  config.filter_run_excluding broken: true
  config.before(:each) do
    Oriented.connection
  end
  
  config.after(:each) do
  end

end
