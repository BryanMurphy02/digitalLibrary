from database import query_database


# return library_table view to show all the books
def get_library_table():
    return query_database("SELECT * FROM library_table")