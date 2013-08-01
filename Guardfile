# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# This eliminates the stty warning.
interactor :simple

guard 'jruby-rspec', :spec_paths => ["spec"] do
  # You can leave this empty and jruby-rspec will not autorun,
  # but it will run all specs in :spec_paths on demand

  # or you can configure it just like guard-rspec
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/integration/.+_spec\.rb$})
  watch(%r{^lib/oriented/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

end

