# timeline
Takes tweets from a bot's followings and markovifies them.

## setup
1. Clone the fucking git repo
2. Install the libraries listed in requirements.txt via pip
3. Rename config.sample.py to config.py and
edit it to fit your needs
4. Create data/simulator.db (SQLite3) by
using data/schema.sql

## running the bot
The bot is not a single piece
of software but instead a collection
of scripts working together and
sometimes depening on each other.  
Automate running them by using cron
or your favorite scheduler.

- fetch.py adds new tweets to the database
- follow.py is a follow4follow whore
- generate.py does the actual thing

Have fun.