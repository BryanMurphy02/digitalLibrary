from database import query_database
from datetime import date

#returns a row from the table
def get_row():
    result = query_database("SELECT * FROM reading_calendar LIMIT 1")
    return result[0] if result else None

# get all
def get_all_reading_calendar():
    return query_database("SELECT * FROM reading_calendar")

#Returns row of reading calendar table matching the inputted session_id
def get_reading_calendar_by_id(id):
    return query_database("SELECT * FROM reading_calendar WHERE session_id = %s", (id,), fetchone=True)

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

#update reading calendar entry
#updates fields of a reading entry by the provided information
#Update entry for a specific user/book/date
#update_reading_entry(1, 10, date(2025, 9, 2), start_page=75, end_page=120)

def update_reading_entry(user_id, book_id, read_date, **kwargs):
    if not kwargs:
        raise ValueError("No fields inputted")

    # Allowed columns for reading_calendar table (excluding identifying keys)
    allowed_cols = {"start_page", "end_page"}

    set_clauses = []
    values = []

    # Build SET clauses dynamically and validate column names
    for col, val in kwargs.items():
        if col not in allowed_cols:
            raise ValueError(f"Invalid column: {col}")
        set_clauses.append(f"{col} = %s")
        values.append(val)

    set_clause = ", ".join(set_clauses)

    # Build SQL query
    query = f"""
        UPDATE reading_calendar
        SET {set_clause}
        WHERE user_id = %s AND book_id = %s AND read_date = %s
        RETURNING *;
    """
    values.extend([user_id, book_id, read_date])

    # Execute query and return updated row
    row = query_database(query, tuple(values), fetchone=True)
    return row

#update either the user id or book id in a reading entry based of the session id
def update_reading_calendar_ids(session_id, new_user_id=None, new_book_id=None):
    if not new_user_id and not new_book_id:
        raise ValueError("Must provide either new_user_id or new_book_id")

    set_clauses = []
    values = []

    if new_user_id:
        set_clauses.append("user_id = %s")
        values.append(new_user_id)
    if new_book_id:
        set_clauses.append("book_id = %s")
        values.append(new_book_id)

    set_clause = ", ".join(set_clauses)

    query = f"""
        UPDATE reading_calendar
        SET {set_clause}
        WHERE session_id = %s
        RETURNING *;
    """
    values.append(session_id)

    row = query_database(query, tuple(values), fetchone=True)
    return row




#update reading date of a calendar entry
#changes the read_date for a specific user/book entry
#Move a reading entry from Sept 2nd to Sept 3rd
#update_reading_date(1, 10, date(2025, 9, 2), date(2025, 9, 3))

def update_reading_date(user_id, book_id, old_date, new_date):
    if not new_date:
        raise ValueError("New date must be provided")

    query = """
        UPDATE reading_calendar
        SET read_date = %s
        WHERE user_id = %s AND book_id = %s AND read_date = %s
        RETURNING *;
    """
    values = (new_date, user_id, book_id, old_date)

    # Execute query and return updated row
    row = query_database(query, values, fetchone=True)
    return row


#delete a reading entry from the calendar
#removes the entry for a given user, book, and date
#Delete a reading entry for Sept 2nd
#delete_reading_entry(1, 10, date(2025, 9, 2))
def delete_reading_entry(user_id, book_id, read_date):
    query = """
        DELETE FROM reading_calendar
        WHERE user_id = %s AND book_id = %s AND read_date = %s
        RETURNING *;
    """
    values = (user_id, book_id, read_date)

    # Execute query and return deleted row
    row = query_database(query, values, fetchone=True)
    return row

#get all reading calendar entries for a user
#returns the entire reading history of the user
def get_reading_calendar(user_id):
    query = """
        SELECT * FROM reading_calendar
        WHERE user_id = %s
        ORDER BY read_date;
    """
    return query_database(query, (user_id,), fetchone=False)


#get all reading calendar entries for a user from the past week
#returns entries within the last 7 days
def get_reading_calendar_past_week(user_id):
    query = """
        SELECT * FROM reading_calendar
        WHERE user_id = %s
          AND read_date >= CURRENT_DATE - INTERVAL '7 days'
        ORDER BY read_date;
    """
    return query_database(query, (user_id,), fetchone=False)


#Testing
# add_reading_entry(user_id=2, book_id=3, start_page=124, end_page=160, read_date=date(2025, 9, 1))
# add_reading_entry(user_id=2, book_id=3, start_page=124, end_page=160, read_date=date(2025, 9, 1))
# update_reading_calendar_ids(session_id=8, new_user_id=3)

