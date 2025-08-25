import psycopg2
from psycopg2.extras import RealDictCursor #returns python dictionaries for a query instead of tuples

#Connect to the database
def get_connection():
    return psycopg2.connect(
        host = "localhost",
        database = "Digital_Library",
        user = "postgres",
        password = "8623"
    )

#pass in a query statement
def query_database(query, params=None, fetchone=False):
    con = get_connection()
    cur = con.cursor(cursor_factory=RealDictCursor)

    cur.execute(query, params or ()) #uses an empty tuple if there are no params

    data = None
    if query.strip().upper().startswith("SELECT") or "RETURNING" in query.upper():
        if fetchone:
            data = cur.fetchone()
        else:
            data = cur.fetchall()

    con.commit()
    cur.close()
    con.close()
    return data