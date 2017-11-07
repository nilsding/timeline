require 'ruby_markovify'
require 'cgi'

Twittbot::BotPart.new :generate do
  task :generate, desc: 'Tweets something from the markov chain' do
    dataset = fetch_tweets
    model = RubyMarkovify::ArrayText.new(dataset, state_size = 2)
    retries = 10
    while retries > 0
      tweet = CGI.unescapeHTML(model.make_short_sentence(280, tries: 100))
      # TODO: move the if conditions for avg word length etc. to own method
      break if average_word_length(tweet) > 2.0 && unique?(tweet) && unique_words(tweet).length > 2
      retries -= 1
    end
    next if retries == 0 && average_word_length(tweet) <= 2.0 && exists?(tweet) && unique_words(tweet).length > 2

    tweet_obj = bot.tweet(tweet)
    update_post(tweet_obj)
  end

  def fetch_tweets
    rows = dosql("SELECT id, text FROM tweets WHERE deleted_at IS NULL ORDER BY id DESC LIMIT 150", nil, "Tweet Load")
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
    row = dosql("SELECT 1 AS one FROM posts WHERE text = ? LIMIT 1", [text], "Post Exists")
    !row.empty?
  end

  def update_post(tweet)
    id = dosql("SELECT id FROM posts WHERE text = ? LIMIT 1", [tweet.text], "Post Load").first.first
    dosql("UPDATE posts SET tweet_id = ? WHERE id = ?", [tweet.id, id], "Post Update")
  end

  def average_word_length(text)
    word_lengths = text.split(/\s+/).map(&:length)
    word_lengths.reduce(:+) / word_lengths.count.to_f
  end

  def unique_words(text)
    text.downcase.split(/\s+/).uniq
  end
end
