from database import query_database
from services.author_service import get_author_by_name

#Add series
def add_series(name, author_id):
    return query_database("INSERT INTO series (name, author_id) VALUES (%s, %s) RETURNING *;", (name, author_id), fetchone=True)

#update series information
#updates the series by the provided information
def update_series(series_id, **kwargs):
    if not kwargs:
        raise ValueError("No fields inputted")

    # Allowed columns for series table
    allowed_cols = {"name", "author_id"}

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
        UPDATE series
        SET {set_clause}
        WHERE id = %s
        RETURNING *;
    """
    values.append(series_id)

    # Execute query and return updated row
    row = query_database(query, tuple(values), fetchone=True)
    return row

def delete_series(series_id):
    #remove series_id from books first
    query_database("UPDATE books SET series_id = NULL WHERE series_id = %s", (series_id,))
    #delete the series
    query_database("DELETE FROM series WHERE id = %s", (series_id,))

#get series id from name
#if series not found then add series and return id
def get_series_id(name, author_id):
    # Try to fetch existing series
    row = query_database("SELECT id FROM series WHERE name = %s", (name,), fetchone=True)
    if row:
        return row['id']
    
    # Series not found, add it
    new_series = add_series(name, author_id)
    return new_series['id']


#get series
def get_series(series_id):
    return query_database("SELECT * FROM books WHERE series_id = %s", (series_id,), fetchone=False)



#Testing
# add_series("Throne of Glass", get_author_by_name("Sarah J.", "Maas"))
# books = get_series(get_series_id("Throne of Glass"))
# for book in books:
#     print(book)