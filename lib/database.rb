require 'sqlite3'

$db = SQLite3::Database.new(File.expand_path("../../data/simulator.db", __FILE__))

Twittbot::BotPart.new :database do
  on :load do
    $db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        screen_name TEXT,
        created_at INTEGER
      );
SQL
    $db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS tweets (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        text TEXT,
        created_at INTEGER
      );
SQL
    $db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY,
        text TEXT,
        created_at INTEGER
      );
SQL
  end
end
