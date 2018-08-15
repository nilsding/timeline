Twittbot::BotPart.new :fetch do
  if $bot[:stream]
    puts "streaming mode ON"

    on :tweet do |tweet, opts|
      # only require tweets from user stream
      next unless opts[:stream_type] == :user
      next unless clean?(tweet, opts)

      upsert_user(tweet.user)

      begin
        dosql("INSERT INTO tweets (id, user_id, text, created_at) VALUES (?, ?, ?, ?)",
              [tweet.id, tweet.user.id, tweet.expanded_text, tweet.created_at.to_i],
              "Tweet Insert")
      rescue => e
        puts "Exception while inserting tweet: #{e.message}"
      end
    end

    on :deleted do |tweet, opts|
      next unless opts[:stream_type] == :user

      begin
        dosql("UPDATE tweets SET deleted_at = ? WHERE id = ?",
              [Time.now.to_i, tweet.id],
              "Tweet Delete")
      rescue => e
        puts "Exception while marking tweet as deleted: #{e.message}"
      end
    end
  else
    puts ":: streaming mode OFF, will fetch periodically (every minute or so)"

    every 1, :minute do
      until (tweets = fetch_tweets_since(last_id)).empty?
        tweets.each do |tweet|
          next unless clean?(tweet, retweet: tweet.retweet?)
          upsert_user(tweet.user)

          begin
            dosql("INSERT INTO tweets (id, user_id, text, created_at) VALUES (?, ?, ?, ?)",
                  [tweet.id, tweet.user.id, tweet.expanded_text, tweet.created_at.to_i],
                  "Tweet Insert")
          rescue => e
            puts "Exception while inserting tweet: #{e.message}"
          end
        end
      end
    end

    def last_id
      dosql("SELECT MAX(id) FROM tweets;", nil, "Tweet Load").first[0]
    end

    def fetch_tweets_since(id)
      $bot[:client].home_timeline(since_id: id, count: 800, include_rts: false)
    rescue => e
      puts "exception while fetching tweets: #{e.class} (#{e.message})"
      puts "returning empty set"
      []
    end
  end

  def clean?(tweet, opts)
    return false if opts[:retweet]

    filter_users = [@config[:screen_name], 'SolideSchlange']
    filter_users.each do |user|
      return false if tweet.user.screen_name.downcase == user.downcase
    end

    filter_regexps = [
      /@/,               # Mentions
      /t\.co/,           # Links
      /\ART\s+/,         # Old-style retweets
      /[\u5350\u534d]/,  # "Friendship Windmill"
      /\u262d/           # Communist propaganda
    ]
    filter_regexps.each do |regexp|
      return false if tweet.expanded_text =~ regexp
    end

    true
  end

  def upsert_user(user)
    dosql("INSERT OR REPLACE INTO users (id, screen_name, created_at, protected) VALUES (?, ?, ?, ?);",
          [user.id, user.screen_name, user.created_at.to_i, (user.protected? ? 1 : 0)],
          "User Upsert")
  rescue => e
    puts "Exception while upserting user: #{e.message}"
  end
end
