require 'ruby_markovify'

Twittbot::BotPart.new :generate do
  class SimulatorText < RubyMarkovify::Text
    def sentence_split(text)
      text.split('<>')
    end
  end

  task :generate, desc: 'Tweets something from the markov chain' do
    dataset = fetch_tweets
    model = SimulatorText.new(dataset, state_size = 2)
    retries = 100
    while retries > 0
      tweet = model.make_short_sentence(140, tries: 100)
      break if unique?(tweet)
      retries -= 1
    end
    next if retries == 0 && exists?(tweet)

    puts tweet
    #bot.tweet(tweet)
  end

  def fetch_tweets
    rows = dosql("SELECT id, text FROM tweets ORDER BY id DESC LIMIT 150", desc = "Tweet Load")
    rows.map{ |row| row[1] }.join('<>')
  end

  def unique?(text)
    return false if exists?(text)
    dosql("INSERT INTO posts (text, created_at) VALUES (?, ?);",
          [text, Time.now.to_i],
          "Post Insert")
    true
  end

  def exists?(text)
    row = dosql("SELECT 1 AS one FROM posts WHERE text = ? LIMIT 1", [text], "Tweet Exists")
    !row.empty?
  end
end
