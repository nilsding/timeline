Twittbot::BotPart.new :fetch do
  on :tweet do |tweet, opts|
    # only require tweets from user stream
    next unless opts[:stream_type] == :user
    next unless clean?(tweet, opts)

    upsert_user(tweet.user)

    begin
      dosql("INSERT INTO tweets (id, user_id, text, created_at) VALUES (?, ?, ?, ?)",
            [tweet.id, tweet.user.id, tweet.text, tweet.created_at.to_i],
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

  def clean?(tweet, opts)
    return false if opts[:retweet]

    filter_users = [@config[:screen_name], 'SolideSchlange']
    filter_users.each do |user|
      return false if tweet.user.screen_name.downcase == user.downcase
    end

    filter_regexps = [/@/, /t\.co/, /\ART/]
    filter_regexps.each do |regexp|
      return false if tweet.text =~ regexp
    end

    true
  end

  def upsert_user(user)
    dosql("INSERT OR REPLACE INTO users (id, screen_name, created_at) VALUES (?, ?, ?);",
          [user.id, user.screen_name, user.created_at.to_i],
          "User Upsert")
  rescue => e
    puts "Exception while upserting user: #{e.message}"
  end
end
