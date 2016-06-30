import sqlite3

import config

def reset():
    print('Clearing recent tweets list.')
    with open(config.RECENT_DB, 'w') as f:
        f.write('[]')

    db_connection = sqlite3.connect(config.SQLITE_DB)
    db_cursor = db_connection.cursor()
    
    print('Dropping table [tweets].')
    try:
        db_cursor.execute('DROP TABLE tweets;')
    except sqlite3.OperationalError:
        print('No table [tweets].')

    print('Recreating database from schema.sql')
    with open(config.SQLITE_SC) as f:
        db_cursor.executescript(f.read())

    db_connection.commit()
    db_connection.close()

    print('Done.')

if __name__ == '__main__':
    reset()
