Twittbot::BotPart.new :fetch do
  on :tweet do |tweet, opts|
    # only require tweets from user stream
    next unless opts[:stream_type] == :user
    next unless clean?(tweet, opts)

    puts 'Inserting tweet ID ' + tweet.id.to_s
    upsert_user(tweet.user)


    begin
      $db.execute("INSERT INTO tweets (id, user_id, text, created_at) VALUES (?, ?, ?, ?)",
                  [tweet.id, tweet.user.id, tweet.text, tweet.created_at.to_i])
    rescue => e
      puts "Exception while inserting tweets to database: #{e.message}"
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
    $db.execute("INSERT OR REPLACE INTO users (id, screen_name, created_at) VALUES (?, ?, ?);",
                [user.id, user.screen_name, user.created_at.to_i])
  rescue => e
    puts "Exception while upserting user: #{e.message}"
  end
end
