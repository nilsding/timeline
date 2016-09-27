import sqlite3

import config
import utils

def latest_tweet_id():
    db_connection = sqlite3.connect(config.SQLITE_DB)
    db_cursor = db_connection.cursor()
    db_cursor.execute('SELECT * FROM tweets WHERE id=(SELECT max(id) FROM tweets)')
    res = db_cursor.fetchone()
    db_connection.close()

    if res is not None:
        return res[2]
    else:
        return None

def fetch_tweets():
    api = utils.get_api()

    statuses = api.home_timeline(count=150, since_id=latest_tweet_id())

    db_connection = sqlite3.connect(config.SQLITE_DB)
    db_cursor = db_connection.cursor()

    for status in filter(utils.is_clean, statuses):
        print(status.author.screen_name)
        print(status.created_at)
        print()
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

if __name__ == '__main__':
    fetch_tweets()
