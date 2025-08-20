from database import query_database


#books table methods

#returns a list of all of the books in books table with all their attributes
def get_all_books():
    return query_database("SELECT * FROM books")

#returns the book specific to the id that is passed in
#important that book id is a single-element tuple
def get_book(book_id):
    return query_database("SELECT * FROM books WHERE id = %s", (book_id,), fetchone=True)

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
print(get_user_book_session(3, 1))