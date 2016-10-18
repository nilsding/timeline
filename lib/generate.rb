require 'ruby_markovify'

Twittbot::BotPart.new :generate do
  task :generate, desc: 'Tweets something from the markov chain' do
    dataset = fetch_tweets
    model = RubyMarkovify::ArrayText.new(dataset, state_size = 2)
    retries = 10
    while retries > 0
      tweet = model.make_short_sentence(140, tries: 100)
      break if unique?(tweet)
      retries -= 1
    end
    next if retries == 0 && exists?(tweet)

    tweet_obj = bot.tweet(tweet)
    update_post(tweet_obj)
  end

  def fetch_tweets
    rows = dosql("SELECT id, text FROM tweets ORDER BY id DESC LIMIT 150", nil, "Tweet Load")
    rows.map{ |row| row[1] }
  end

  def unique?(text)
    return false if text.nil?
    return false if exists?(text)
    dosql("INSERT INTO posts (text, created_at) VALUES (?, ?);",
          [text, Time.now.to_i],
          "Post Insert")
    true
  end

  def exists?(text)
    return true if text.nil?
    row = dosql("SELECT 1 AS one FROM posts WHERE text = ? LIMIT 1", [text], "Tweet Exists")
    !row.empty?
  end

  def update_post(tweet)
    id = dosql("SELECT id FROM posts WHERE text = ? LIMIT 1", [tweet.text], "Post Load").first.first
    dosql("UPDATE posts SET tweet_id = ? WHERE id = ?", [tweet.id, id], "Post Update")
  end
end
