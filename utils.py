import tweepy

from config import *

def get_api():
    auth = tweepy.OAuthHandler(CONSUM_TOK, CONSUM_SEC)
    auth.set_access_token(ACCESS_TOK, ACCESS_SEC)

    return tweepy.API(auth)
