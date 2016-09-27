import sqlite3

import config
import sqlite3

import tweepy

import config
import utils

class TimelineListener(tweepy.StreamListener):

    buffer = []

    def on_status(self, status):
        if utils.is_clean(status):
            self.buffer.append(status)
            print(status.text)
            print('Buffer: ' + str(len(self.buffer)))

            if len(self.buffer) >= 5:
                print('Buffer is 5! saving...')

                db_connection = sqlite3.connect(config.SQLITE_DB)
                db_cursor = db_connection.cursor()

                for status in self.buffer:
                    db_cursor.execute(
                        'INSERT INTO tweets VALUES (?,?,?,?)',
                        (
                            status.author.screen_name,
                            status.text,
                            status.id,
                            status.created_at.timestamp(),
                        )
                    )
                db_connection.commit()
                db_connection.close()

                print('Buffer is cleaning...')
                self.buffer = []

def fetch_tweets():
    api = utils.get_api()

    timeline_listener = TimelineListener()
    timeline_stream = tweepy.Stream(auth=api.auth, listener=timeline_listener)
    timeline_stream.userstream()


if __name__ == '__main__':
    fetch_tweets()
