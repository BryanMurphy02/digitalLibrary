from flask_login import UserMixin
from services import user_service

class User(UserMixin):
    def __init__(self, id, email, password_hash):
        self.id = id
        self.email = email
        self.password_hash = password_hash




def get_user_by_id(user_id):
    result = user_service.get_user_by_id(user_id)

    return User(
        id=result["id"],
        email=result["email"],
        password_hash=result["password_hash"]
    )


def get_user_by_email(email):
    result = user_service.get_user_by_email(email)

    return User(
        id=result["id"],
        email=result["email"],
        password_hash=result["password_hash"]
    )


def register_user(email, password_hash):
    user_service.register_user(email, password_hash)