from database import query_database
from services.author_service import add_author, get_author_by_name
from services.series_service import get_series_id


#books table methods
#returns a row from the table
def get_row():
    result = query_database("SELECT * FROM books LIMIT 1")
    return result[0] if result else None

#returns a list of all of the books in books table with all their attributes
def get_all_books():
    return query_database("SELECT * FROM books")

#Returns row of books table matching the inputted id
def get_book_by_id(id):
    return query_database("SELECT * FROM books WHERE id = %s", (id,))

#returns the book specific to the id that is passed in
#important that book id is a single-element tuple
def get_book(book_id):
    return query_database("SELECT * FROM books WHERE id = %s", (book_id,), fetchone=True)

#get book id by book name and returns id INT
def get_book_id(book_title):
    row = query_database("SELECT id FROM books WHERE title = %s", (book_title,), fetchone=True)
    return row['id'] if row else None

#returns all the books by a specific author by passing in author id
def get_books_by_author(author_id):
    return query_database("SELECT * FROM books WHERE author_id = %s", (author_id,))

#returns the book by a specific name
def get_book_by_title(book_name):
    return query_database("SELECT * FROM books WHERE title = %s", (book_name,), fetchone=True)

#returns all the books in a series by passing in the series id
def get_books_in_series(series_id):
    return query_database("SELECT * FROM books WHERE series_id = %s", (series_id,))

#returns the books in a genre by passing in the genre id
def get_books_by_genre(genre_id):
    return query_database("SELECT * FROM book_genre_map WHERE genre_id = %s", (genre_id,))

#returns the genre's of a book by passing in the book id
def get_genre_of_book(book_id):
    return query_database("SELECT * FROM book_genre_map WHERE book_id = %s", (book_id,))

# check to see if a book is already within database
# Returns true if book is in database (based off title and author) and returns false if not
def check_book(book_name, book_author):
    row = get_book_by_title(book_name)
    row2 = get_books_by_author(book_author)
    if(row is None or row is None):
        return True
    else:
        return False

#add/create books
#required params are book title, author first + last name
#optional params cover, page count, series id, author id, series order
def add_book(book_title, author_first_name, author_last_name, cover=None, page_count=None, series_id=None, author_id=None, series_order=None):
    #Get the author id if not passed in
    if author_id is None:
        author_id = add_author(author_first_name, author_last_name)

    row = query_database(
        "INSERT INTO books (title, cover, page_count, series_id, author_id, series_order) VALUES (%s,%s,%s,%s,%s,%s) RETURNING *;",
        (book_title, cover, page_count, series_id, author_id, series_order),
        fetchone=True
    )
    return row
    
        
    # INSERT INTO user_books (book_id, user_id) VALUES (%s, %s) RETURNING *;

#update book information
#updates the book by the provided information
def update_book(book_id, **kwargs):
    #**kwargs means to take any passed in args and put them into a dictionary
    if not kwargs:
        raise ValueError("No fields inputted")
    
    #rigid set of column names to catch any typos or non-existing columns
    allowed_cols = {"title", "cover", "page_count", "series_id", "author_id", "series_order"}
    
    #holds the column name such as title = %s
    set_clauses = []
    #holds the actual values of the column such as "The Way of Kings"
    values = []
    #enumerate through kwargs starting with the first entry and match the column name with the inputted value
    for i, (col, val) in enumerate(kwargs.items(), start=1):
        if col not in allowed_cols:
            raise ValueError(f"Invalid column: {col}")
        set_clauses.append(f"{col} = %s")
        values.append(val)

    #turns the clauses into one part such as combining title = %s and author = %s into "title=%s, author=%s"
    set_clause = ", ".join(set_clauses)
    
    #building sql statements with the clauses
    query = f"""
        UPDATE books
        SET {set_clause}
        WHERE id = %s
        RETURNING *;
    """
    #adding book id so that the book can be picked in the sql query
    values.append(book_id)

    #actually adding the updated information
    #casting the list values into tuples to be used
    row = query_database(query, tuple(values), fetchone=True)
    return row

#delete a book from the database
def delete_book(book_id):
    query_database("DELETE FROM books WHERE id = %s", (book_id,))


#User_book table methods

#returns session ids for inputted book and user
def get_user_book_session(book_id, user_id):
    return query_database("SELECT session_id FROM user_books WHERE book_id = %s AND user_id = %s", (book_id, user_id))

#returns the status of a book in a user's library
def get_user_book_status(book_id, user_id):
    return query_database("SELECT status FROM user_books WHERE book_id = %s AND user_id = %s", (book_id, user_id), fetchone=True)

# returns the start_date of a book in a user's library
def get_user_book_start_date(book_id, user_id):
    return query_database(
        "SELECT start_date FROM user_books WHERE book_id = %s AND user_id = %s",
        (book_id, user_id),
        fetchone=True
    )

#returns the completed_date of a book in a user's library
def get_user_book_completed_date(book_id, user_id):
    return query_database(
        "SELECT completed_date FROM user_books WHERE book_id = %s AND user_id = %s",
        (book_id, user_id),
        fetchone=True
    )

#returns the user_id for a given book session (if needed)
def get_user_book_user_id(book_id, session_id):
    return query_database(
        "SELECT user_id FROM user_books WHERE book_id = %s AND session_id = %s",
        (book_id, session_id),
        fetchone=True
    )

#returns the book_id for a given user session (if needed)
def get_user_book_book_id(user_id, session_id):
    return query_database(
        "SELECT book_id FROM user_books WHERE user_id = %s AND session_id = %s",
        (user_id, session_id),
        fetchone=True
    )

#add a book to user's to be read books (To Be Read set as default in postgres database) if not alread in list
def add_user_book(book_id, user_id):
    row = get_user_book_status(book_id, user_id)

    if row and row['status'] == 'To Be Read':
        return {"error":"This book is already in your To Be Read list"}
    return query_database(
    "INSERT INTO user_books (book_id, user_id) VALUES (%s, %s) RETURNING *;", 
        (book_id, user_id),
        fetchone=True
    )



#dynamic get methods for user_book table (chatGPT written)
def get_user_book_column(column_name, book_id, user_id):
    allowed_columns = {'session_id', 'status', 'start_date', 'completed_date', 'user_id', 'book_id'}
    
    if column_name not in allowed_columns:
        raise ValueError(f"Invalid column: {column_name}")
    
    query = f"SELECT {column_name} FROM user_books WHERE book_id = %s AND user_id = %s"
    return query_database(query, (book_id, user_id), fetchone=True)

# Generic getter for any column by session_id
def get_user_book_column_by_session(column_name, session_id):
    allowed_columns = {'session_id', 'status', 'start_date', 'completed_date', 'user_id', 'book_id'}
    
    if column_name not in allowed_columns:
        raise ValueError(f"Invalid column: {column_name}")
    
    query = f"SELECT {column_name} FROM user_books WHERE session_id = %s"
    return query_database(query, (session_id,), fetchone=True)



#Testing
# update_book(8, page_count=603)
# add_book("Small Gods", "Terry", "Pratchett")
# print(get_book_id("Small Gods"))
# delete_book(get_book_id("Small Gods"))

# update_book(get_book_id("The Blade Itself"), series_id=get_series_id("The First Law"), series_order=1)
# update_book(get_book_id("Before they are Hanged"), series_id=get_series_id("The First Law"), series_order=2)
# update_book(get_book_id("Last Argument of Kings"), series_id=get_series_id("The First Law"), series_order=3)

# add_book("Dungeon Crawler Carl", "Matt", "Dinniman", page_count = 446, series_id= get_series_id("Dungeon Crawler Carl", add_author("Matt", "Dinniman")), series_order= 1)
# add_book("Carl's Doomsday Scenario", "Matt", "Dinniman", page_count = 364, series_id= get_series_id("Dungeon Crawler Carl", add_author("Matt", "Dinniman")), series_order= 2)
# add_book("The Dungeon Anarchist's Cookbook", "Matt", "Dinniman", page_count = 534, series_id= get_series_id("Dungeon Crawler Carl", add_author("Matt", "Dinniman")), series_order= 3)
# add_book("The Gate of the Feral Gods", "Matt", "Dinniman", page_count = 586, series_id= get_series_id("Dungeon Crawler Carl", add_author("Matt", "Dinniman")), series_order= 4)
# add_book("The Butcher's Masquerade", "Matt", "Dinniman", page_count = 732, series_id= get_series_id("Dungeon Crawler Carl", add_author("Matt", "Dinniman")), series_order= 5)
# add_book("The Eye of the Bedlam Bride", "Matt", "Dinniman", page_count = 694, series_id= get_series_id("Dungeon Crawler Carl", add_author("Matt", "Dinniman")), series_order= 6)
# add_book("This Inevitable Ruin", "Matt", "Dinniman", page_count = 724, series_id= get_series_id("Dungeon Crawler Carl", add_author("Matt", "Dinniman")), series_order= 7)


# update_book(
#     book_id=18,
#     cover="images/books/dungeon_crawler_carl.jpg"
# )

# update_book(
#     book_id=19,
#     cover="images/books/carl's_doomsday_scenario.jpg"
# )

# update_book(
#     book_id=20,
#     cover="images/books/the_dungeon_anarchist's_cookbook.jpg"
# )

# update_book(
#     book_id=21,
#     cover="images/books/the_gate_of_the_feral_gods.jpg"
# )

# update_book(
#     book_id=22,
#     cover="images/books/the_butcher's_masquerade.jpg"
# )

# update_book(
#     book_id=23,
#     cover="images/books/the_eye_of_the_bedlam_bride.jpg"
# )

# update_book(
#     book_id=24,
#     cover="images/books/this_inevitable_ruin.jpg"
# )