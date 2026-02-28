from database import query_database


# return library_table view to show all the books
def get_library_table():
    return query_database("SELECT * FROM library_table")

# input the book id and then return the row from book_display database view
def get_display_book(id):
    return query_database("SELECT * FROM book_display WHERE book_id = %s", (id,), fetchone=True)