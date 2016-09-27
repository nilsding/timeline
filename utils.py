import tweepy

from config import *

def get_api():
    auth = tweepy.OAuthHandler(CONSUM_TOK, CONSUM_SEC)
    auth.set_access_token(ACCESS_TOK, ACCESS_SEC)

    return tweepy.API(auth)

def is_clean(status):
    return (not '@' in status.text) \
            and (not 'RT' in status.text.lower()) \
            and (not 't.co' in status.text.lower()) \
            and (not 'simulator' in status.author.screen_name.lower()) \
            and (not 'SolideSchlange' in status.author.screen_name)