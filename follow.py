import time

import tweepy

from config import *

auth = tweepy.OAuthHandler(CONSUM_TOK, CONSUM_SEC)
auth.set_access_token(ACCESS_TOK, ACCESS_SEC)

api = tweepy.API(auth)

def limit_rate(cursor):
    while 1:
        try:
            yield cursor.next()
        except tweepy.RateLimitError:
            print('rate limit exceeded -> sleeping 15.25min')
            time.sleep(15 * 61) # better be sure

for follower in limit_rate(tweepy.Cursor(api.followers).items()):
    print('-> following @%s' % follower.screen_name)
    follower.follow()
