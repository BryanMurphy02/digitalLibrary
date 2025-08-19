from database import query_database

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

