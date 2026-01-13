from database import query_database

#returns a row from the table
def get_row():
    result = query_database("SELECT * FROM author LIMIT 1")
    return result[0] if result else None


#Get all authors
def get_all_authors():
    return query_database("SELECT * FROM author")

#Returns row of author table matching the inputted id
def get_author_by_id(id):
    return query_database("SELECT * FROM author WHERE id = %s", (id,))

#Checks to see if there is an author in the database by first and last name
#returns none if not found or id int
def get_author_by_name(first_name, last_name):
    result = query_database("SELECT id FROM author WHERE first_name = %s AND last_name = %s", (first_name, last_name), fetchone=True)
    return result["id"] if result else None

#Get author by id
#returns first and last name
def get_author_name(author_id):
    return query_database("SELECT first_name, last_name FROM author WHERE id = %s", (author_id,), fetchone=True)

#Adds an author to database
#Checks to see if author exists in database and if not then adds and returns id
def add_author(first_name, last_name):
    result = get_author_by_name(first_name, last_name)
    if result is None:
        query_database(
            "INSERT INTO author (first_name, last_name) VALUES (%s, %s) RETURNING *;",
            (first_name, last_name),
            fetchone=True
        )
        return get_author_by_name(first_name, last_name)
    else:
        return get_author_by_name(first_name, last_name)

#get author id by first and last name and returns id INT
def get_author_id(first_name, last_name):
    row = query_database("SELECT id FROM author WHERE first_name = %s AND last_name = %s", (first_name,last_name), fetchone=True)
    return row['id'] if row else None

#update author information
#updates the author by the provided information
def update_author(author_id, **kwargs):
    if not kwargs:
        raise ValueError("No fields inputted")

    # Allowed columns for author table
    allowed_cols = {"first_name", "last_name"}  # add more if your author table has extra columns

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
        UPDATE author
        SET {set_clause}
        WHERE id = %s
        RETURNING *;
    """
    values.append(author_id)

    # Execute query and return updated row
    row = query_database(query, tuple(values), fetchone=True)
    return row


#delete an author from the database
def delete_author(author_id):
    query_database("DELETE FROM author WHERE id = %s", (author_id,))



#Testing
# print(get_author_name(3))
# add_author("Jillian", "Desmond")
# delete_author(get_author_id("Jillian", "Murphy"))
# update_author(get_author_id("Jillian", "Desmond"), last_name="Murphy")