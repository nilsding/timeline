require 'sqlite3'

$db = SQLite3::Database.new(File.expand_path("../../data/simulator.db", __FILE__))
