import tweepy

from config import *

auth = tweepy.OAuthHandler(CONSUM_TOK, CONSUM_SEC)
url = auth.get_authorization_url()
print(url)
verifier = input('verifier?> ')
print(auth.get_access_token(verifier))
