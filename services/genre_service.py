from database import query_database

#Genre table

#returns a row from the table
def get_row():
    result = query_database("SELECT * FROM genre LIMIT 1")
    return result[0] if result else None

# get all the genres
def get_all_genres():
    return query_database("SELECT * FROM genre")

#Returns row of genre table matching the inputted id
def get_genre_by_id(id):
    return query_database("SELECT * FROM genre WHERE id = %s", (id,), fetchone=True)

#add genre
def add_genre(name):
    return query_database("INSERT INTO genre (name) VALUES (%s) RETURNING *;", (name,), fetchone=True)

#def get genre id, returns INT
#If the genre is not found then the genre is added and return id
def get_genre_id(name):
    # Try to fetch existing genre
    row = query_database("SELECT id FROM genre WHERE name = %s", (name,), fetchone=True)
    if row:
        return row['id']
    
    # Genre not found, add it
    new_genre = add_genre(name)
    return new_genre['id']

#get genre name by id
def get_genre_name(id):
    row = query_database("SELECT name FROM genre WHERE id = %s", (id,), fetchone=True)
    return row['name'] if row else None

#update genre information
#updates the genre by the provided information
def update_genre(genre_id, **kwargs):
    if not kwargs:
        raise ValueError("No fields inputted")

    # Allowed columns for genre table
    allowed_cols = {"name"}

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
        UPDATE genre
        SET {set_clause}
        WHERE id = %s
        RETURNING *;
    """
    values.append(genre_id)

    # Execute query and return updated row
    row = query_database(query, tuple(values), fetchone=True)
    return row


#delete a genre by id
def delete_genre(genre_id):
    #remove genre from book_genre_map first
    query_database("DELETE FROM book_genre_map WHERE genre_id = %s", (genre_id,))
    #delete the genre
    query_database("DELETE FROM genre WHERE id = %s", (genre_id,))




#Book Genre Map

#add book genre connection
def add_book_genre_map(book_id, genre_id):
    return query_database("INSERT INTO book_genre_map (book_id, genre_id) VALUES (%s, %s) RETURNING *;", (book_id, genre_id), fetchone=True)


#update book_genre_map information
#updates the mapping by the provided information
def update_book_genre_map(book_id, **kwargs):
    if not kwargs:
        raise ValueError("No fields inputted")

    # Allowed columns for book_genre_map table
    allowed_cols = {"genre_id"}

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
        UPDATE book_genre_map
        SET {set_clause}
        WHERE book_id = %s
        RETURNING *;
    """
    values.append(book_id)

    # Execute query and return updated row
    row = query_database(query, tuple(values), fetchone=True)
    return row

#remove all book mappings for a genre
def remove_genre_mappings(genre_id):
    query_database("DELETE FROM book_genre_map WHERE genre_id = %s", (genre_id,))

#assigns the passed in genres to a passed in book
def add_genres_to_book(book_id, *genre_names):
    for name in genre_names:
        add_book_genre_map(book_id, get_genre_id(name))



#Testing

