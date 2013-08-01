require 'fileutils'
return if defined?(DB_CREATED)

GEM_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..' ))
DB_PATH = "#{GEM_PATH}/spec/databases"
TMP_DB_PATH = "#{DB_PATH}/db_#{rand(999) + 1}"
FileUtils.remove_dir DB_PATH rescue nil
FileUtils.mkdir_p TMP_DB_PATH
puts "making #{TMP_DB_PATH}"
odb = OrientDB::DocumentDatabase.new("local:#{TMP_DB_PATH}").create
DB = OrientDB::OrientGraph.new("local:#{TMP_DB_PATH}")

DB_CREATED = true
