from database import query_database

#Get all authors
def get_all_authors():
    return query_database("SELECT * FROM author")

#Get author id by first and last name
#returns none if not found
def get_author_by_name(first_name, last_name):
    result = query_database("SELECT id FROM author WHERE first_name = %s AND last_name = %s", (first_name, last_name), fetchone=True)
    return result["id"] if result else None

#Get author by id
def get_author_name(author_id):
    return query_database("SELECT first_name, last_name FROM author WHERE id = %s", (author_id,), fetchone=True)

#Adds an author to database
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






#Testing
print(get_author_name(3))