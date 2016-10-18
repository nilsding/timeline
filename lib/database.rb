require 'sqlite3'

$db = SQLite3::Database.new(File.expand_path("../../data/simulator.db", __FILE__))
$db_output_color = 35

def dosql(sql, args = nil, desc = "SQL")
  puts "\033[34;1m  #{desc}  \033[#{$db_output_color};1m #{sql}   \033[0;1m#{args.nil? ? '' : args.inspect}\033[0m" if $bot[:config][:debug]
  $db_output_color = $db_output_color == 35 ? 36 : 35
  $db.execute(sql, args)
end

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
        created_at INTEGER,
        tweet_id INTEGER
      );
SQL
  end

  task :reset_tweets, desc: 'Reset the tweets database' do
    dosql("DELETE FROM tweets;")
  end

  task :reset_posts, desc: 'Reset the posts database' do
    dosql("DELETE FROM posts;")
  end
end
