require 'sqlite3'

$db = SQLite3::Database.new(File.expand_path("../../data/simulator.db", __FILE__))
$db_output_color = 35

def dosql(sql, args = nil, desc = "SQL")
  puts "\033[34;1m  #{desc}  \033[#{$db_output_color};1m #{sql}   \033[0;1m#{args.nil? ? '' : args.inspect}\033[0m" if $bot[:config][:debug]
  $db_output_color = $db_output_color == 35 ? 36 : 35
  $db.execute(sql, args)
end

Twittbot::BotPart.new :database do

  TARGET_SCHEMA = 2

  on :load do
    do_migration if current_schema_version < TARGET_SCHEMA
  end

  task :migrate, desc: 'Migrate the database to the current version' do
    do_migration
  end

  task :reset_tweets, desc: 'Reset the tweets database' do
    dosql("DELETE FROM tweets;")
  end

  task :reset_posts, desc: 'Reset the posts database' do
    dosql("DELETE FROM posts;")
  end

  def do_migration
    currver = current_schema_version
    while currver < TARGET_SCHEMA
      migrate_db(currver + 1)
      currver = current_schema_version
    end
  end

  def current_schema_version
    return dosql("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1")
           .flatten.first || 0
  rescue SQLite3::SQLException => _
    return 0
  end

  def migrate_db(target_version)
    should_update = false
    start = Time.now
    puts "========  Migrating to version #{target_version}"
    case target_version
    when 1
      should_update = true
      dosql <<-SQL
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version INTEGER PRIMARY KEY
      );
SQL
      dosql <<-SQL
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY,
          screen_name TEXT,
          created_at INTEGER
        );
SQL
      dosql <<-SQL
        CREATE TABLE IF NOT EXISTS tweets (
          id INTEGER PRIMARY KEY,
          user_id INTEGER,
          text TEXT,
          created_at INTEGER
        );
SQL
      dosql <<-SQL
        CREATE TABLE IF NOT EXISTS posts (
          id INTEGER PRIMARY KEY,
          text TEXT,
          created_at INTEGER,
          tweet_id INTEGER
        );
SQL
    when 2
      should_update = true
      dosql("ALTER TABLE tweets ADD COLUMN deleted_at INTEGER;")
    end
    update_schema_migrations(target_version) if should_update
    puts "========  Migration successful.  Took #{(Time.now - start).round(3).to_s.ljust(5, '0')}s"
  end

  def update_schema_migrations(target_version)
    dosql("INSERT INTO schema_migrations (version) VALUES (?)", [target_version])
  end
end
