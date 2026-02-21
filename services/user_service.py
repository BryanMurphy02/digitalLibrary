from database import query_database
import bcrypt
import psycopg2
from psycopg2 import errors

# importing for user auth from flask_login
from routes.user_route import User

#puts in a password string and returns an encrypted password
def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')  # store as string in DB

#returns a row from the table
def get_row():
    result = query_database("SELECT * FROM users LIMIT 1")
    return result[0] if result else None

# get all
def get_all_users():
    return query_database("SELECT * FROM users")

# Implemented with User class from user_route which uses flask_login
def get_user_by_id(user_id):
    result = query_database(
        "SELECT * FROM users WHERE id = %s",
        (user_id,),
        fetchone=True
    )

    if not result:
        return None
    
    return result

# Implemented with User class from user_route which uses flask_login
def get_user_by_email(email):
    result = query_database(
        "SELECT id, email, username, password_hash FROM users WHERE email = %s",
        (email,),
        fetchone=True
    )

    if not result:
        return None
    
    return result


def register_user(email, username, password_hash):
    query_database(
            "INSERT INTO users (email, username, password_hash) VALUES (%s, %s, %s)",
            (email, username, password_hash)
        )


    

# # add a user
# def add_user(email, username, password):
#     hashed = hash_password(password)
#     try:
#         return query_database(
#             """
#             INSERT INTO users (email, username, password_hash)
#             VALUES (%s, %s, %s)
#             RETURNING id, email, username
#             """,
#             (email, username, hashed),
#             fetchone=True
#         )
#     except psycopg2.errors.UniqueViolation:
#         # Raised if email or username already exists
#         raise ValueError("Email or username already exists. Please choose a different one.")
    
# # verify a user's password
# def verify_password(email_or_username, password):
#     # fetch the stored hash from the database
#     row = query_database(
#         "SELECT password_hash FROM users WHERE email = %s OR username = %s",
#         (email_or_username, email_or_username),
#         fetchone=True
#     )
    
#     if not row:
#         return False  # user not found
    
#     stored_hash = row['password_hash']
    
#     # check password against hash
#     return bcrypt.checkpw(password.encode('utf-8'), stored_hash.encode('utf-8'))


#update the user password
def reset_password(user_id, new_password):
    hashed = hash_password(new_password)
    query_database(
        "UPDATE users SET password_hash = %s WHERE id = %s",
        (hashed, user_id)
    )


# get user id from username
def get_user_id(username):
    row = query_database(
        "SELECT id FROM users WHERE username = %s",
        (username,),
        fetchone=True
    )
    return row['id'] if row else None


# get username from id
def get_user_username(user_id):
    row = query_database(
        "SELECT username FROM users WHERE id = %s",
        (user_id,),
        fetchone=True
    )
    return row['username'] if row else None




# Get all the books that are added to the user profile
def get_user_books(user_id):
    return query_database(
        "SELECT * FROM user_book_library WHERE user_id = %s",
        (user_id,),
        fetchone=False
    )




#Testing
# add_user("test2@gmail.com", "Bryan Murphy", "BryanLovesJillian")
# add_user("test2@gmail.com", "Eden", "MrStinker")
# add_user("test3@gmail.com", "Connor Murphy", "Connorisanidiot")