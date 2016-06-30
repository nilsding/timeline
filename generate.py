import json
import sqlite3
import sys

import markovify

import config
import utils

class SimulatorText(markovify.Text):
    def sentence_split(self, text):
        return text.split('<>')

def get_recent_tweets():
    pass

def generate_random_tweet():
    db_connection = sqlite3.connect(config.SQLITE_DB)
    db_cursor = db_connection.cursor()
    db_cursor.execute('SELECT * FROM tweets ORDER BY id DESC LIMIT 2000')

    dataset = ''

    for tweet in db_cursor.fetchall():
        dataset += tweet[1]
        dataset += '<>' # delimiter
    db_connection.close()

    model = SimulatorText(dataset, state_size=3)
    tweet = model.make_short_sentence(140, tries=100)
    if tweet is None:
        sys.exit(0)
    tweet = tweet.replace('&amp;', '&')
    tweet = tweet.replace('&lt;', '<')
    tweet = tweet.replace('&gt;', '>')

    return tweet

def send_random_tweet():
    tweet = generate_random_tweet()
    with open(config.RECENT_DB) as f:
        recent = json.load(f)
    while tweet in recent:
        tweet = generate_random_tweet()

    api = utils.get_api()
    try:
        api.update_status(status=tweet)
    except:
        pass

    recent.append(tweet)
    with open(config.RECENT_DB, 'w') as f:
        json.dump(recent, f)
    return tweet

if __name__ == '__main__':
    t = send_random_tweet()
    print(len(t), t)
