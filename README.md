# timeline

Takes tweets from a bot's followings and markovifies them.

This is the Ruby port of the [original code](https://github.com/sneaksnake/timeline), with some enhancements:

* Database migrations
* Does not use deleted tweets for generation

## Instructions

### Requirements

* Ruby 2.3 or newer
* Bundler (install it using `gem install bundler` if you don't have it already)
* FreeBSD, OpenBSD, macOS or any other decent Unix-like system

### Installation

1. Clone this git repo
2. Run `bundle install` to install the dependencies
3. Authenticate with Twitter: `twittbot auth`
4. Run the bot to start fetching tweets: `twittbot start`
5. Create an entry in your crontab which runs `twittbot cron generate`

Have fun!
