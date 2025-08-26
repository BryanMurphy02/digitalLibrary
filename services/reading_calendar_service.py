from database import query_database
from datetime import date

#add reading entry to the calendar
#defaults to an entry for current date unless another date is passed in
def add_reading_entry(user_id, book_id, start_page, end_page, read_date=None):
    if read_date is None:
        read_date = date.today()
    return query_database(
        "INSERT INTO reading_calendar (user_id, book_id, read_date, start_page, end_page) VALUES (%s,%s,%s,%s,%s) RETURNING *;",
        (user_id, book_id, read_date, start_page, end_page),
        fetchone=True
    )
