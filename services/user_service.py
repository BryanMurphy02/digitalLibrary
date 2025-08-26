from database import query_database
import bcrypt
import psycopg2
from psycopg2 import errors

#puts in a password string and returns an encrypted password
def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')  # store as string in DB

# add a user
def add_user(email, username, password):
    hashed = hash_password(password)
    try:
        return query_database(
            """
            INSERT INTO users (email, username, password_hash)
            VALUES (%s, %s, %s)
            RETURNING id, email, username
            """,
            (email, username, hashed),
            fetchone=True
        )
    except psycopg2.errors.UniqueViolation:
        # Raised if email or username already exists
        raise ValueError("Email or username already exists. Please choose a different one.")


#get user id from username
def get_user_id(username):
    return


#get username from id
def get_user_username(user_id):
    return




#Testing
add_user("test@gmail.com", "Jillian Murphy", "BryanLovesJillian")