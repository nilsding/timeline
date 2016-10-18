# timeline
Takes tweets from a bot's followings and markovifies them.  Currently under a rewrite to Ruby.

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

## Instructions for the old Python version

### setup
1. Clone the fucking git repo
2. Install the libraries listed in requirements.txt via pip
3. Rename config.sample.py to config.py and
edit it to fit your needs
4. Create data/simulator.db (SQLite3) by
using data/schema.sql

### running the bot
The bot is not a single piece
of software but instead a collection
of scripts working together and
sometimes depending on each other.  
Automate running them by using cron
or your favorite scheduler.

- fetch.py adds new tweets to the database
- fetchstream.py is like fetch.py, but always active and using
the Twitter Streaming-API (recommended)
- follow.py is a follow4follow whore (but broken!)
- generate.py does the actual thing

Have fun.
