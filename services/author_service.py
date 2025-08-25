from database import query_database

#Get all authors
def get_all_authors():
    return query_database("SELECT * FROM author")

#Checks to see if there is an author in the database by first and last name
#returns none if not found
def get_author_by_name(first_name, last_name):
    result = query_database("SELECT id FROM author WHERE first_name = %s AND last_name = %s", (first_name, last_name), fetchone=True)
    return result["id"] if result else None

#Get author by id
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

#delete an author from the database
def delete_author(author_id):
    query_database("DELETE FROM author WHERE id = %s", (author_id,))



#Testing
# print(get_author_name(3))
# add_author("Bryan", "Murphy")
delete_author(get_author_id("Bryan", "Murphy"))