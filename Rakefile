require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

# bundle exec rake console
desc "Start a console with Oriented loaded"
task :console do
  require 'irb'
  require 'irb/completion'
  require 'lib/oriented' # You know what to do.
  ARGV.clear
  IRB.start
end

task default: :spec
