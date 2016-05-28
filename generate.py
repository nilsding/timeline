import datetime
import json
import sqlite3

import markovify
import tweepy

import config
import utils

class SimulatorText(markovify.Text):
    def sentence_split(self, text):
        return text.split('<...>')

def get_recent_tweets():
    pass

def generate_random_tweet():
    db_connection = sqlite3.connect(config.SQLITE_DB)
    db_cursor = db_connection.cursor()
    db_cursor.execute('SELECT * FROM tweets')

    dataset = ''

    for tweet in db_cursor.fetchall():
        dataset += tweet[1]
        dataset += '<...>' # delimiter
    #print(dataset)
    db_connection.close()

    dataset.replace('&amp;', '&')
    dataset.replace('&gt;', '>')
    dataset.replace('&lt;', '<')

    model = SimulatorText(dataset, state_size=2)
    tweet = model.make_short_sentence(140, tries=100)

    return tweet

def send_random_tweet():
    tweet = generate_random_tweet()
    with open(config.RECENT_DB) as f:
        recent = json.load(f)
    if len(recent) > 10:
        recent.pop(0)
    while tweet in recent:
        tweet = generate_random_tweet()

    api = utils.get_api()
    api.update_status(status=tweet)

    recent.append(tweet)
    with open(config.RECENT_DB, 'w') as f:
        json.dump(recent, f)
    return tweet

if __name__ == '__main__':
    t = send_random_tweet()
    print(len(t), t)
    #print(get_recent_tweets())