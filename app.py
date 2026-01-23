# Importing flask module in the project is mandatory
# An object of Flask class is our WSGI application.
from flask import Flask, render_template
from flask import request, redirect, url_for, flash
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from werkzeug.utils import secure_filename
import uuid
import os

from routes import master_route, user_route

# Needs to be changed when deploying app
import secrets

# Flask constructor takes the name of 
# current module (__name__) as argument.
app = Flask(__name__)

# Needs to change this if ever not simply in dev mode
app.secret_key = "bryanlovesjillianmore"


# Creating the login object
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "login"

# The route() function of the Flask class is a decorator, 
# which tells the application which URL should call 
# the associated function.
@app.route('/')
# ‘/’ URL is bound with hello_world() function.
def home():
    return render_template("index.html")

@app.route('/library')
def library():
    books = master_route.get_books()
    authors = master_route.get_authors()
    return render_template("library.html", books=books, authors=authors)


@app.route('/profile')
@login_required
def profile():
    user_data = master_route.get_row_by_id("user", current_user.id)
    return render_template("profile.html", user_data=user_data)

@app.route('/reading_calendar')
@login_required
def reading_calendar():
    return render_template("reading_calendar.html")

@app.route('/add_books', methods=['GET', 'POST'])
@login_required
def add_books():
    if request.method == 'POST':
        book_title = request.form.get('book_title')
        author_first_name = request.form.get('author_first_name')
        author_last_name = request.form.get('author_last_name')
        page_count = request.form.get('page_count') or None

        cover_file = request.files.get('cover') or None

        if not book_title or not author_first_name or not author_last_name:
            flash("Title and author fields are required.")
            return redirect(url_for('add_books'))
        
        cover_path = None
        if cover_file and cover_file.filename:
            filename = secure_filename(cover_file.filename)
            ext = filename.rsplit('.', 1)[1]

            filename = f"{uuid.uuid4()}.{ext}"
            cover_path = f"images/books/{filename}"

            cover_file.save(os.path.join("static", cover_path))

        master_route.add_book(
            book_title,
            author_first_name,
            author_last_name,
            page_count,
            cover_path
        )

        flash("Book added successfully!")
        return redirect(url_for('add_books'))

    return render_template("add_books.html")



@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        user = user_route.get_user_by_email(email)

        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            return redirect(url_for('profile'))

        flash("Invalid email or password")

    return render_template("login.html")

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        email = request.form['email']
        username = request.form['username']
        password = request.form['password']

        password_hash = generate_password_hash(password)

        user_route.register_user(email, username, password_hash)

        return redirect(url_for('login'))

    return render_template("register.html")

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('home'))




# Login managar getting the user_id as a string
@login_manager.user_loader
def load_user(user_id):
    return user_route.get_user_by_id(user_id)

# main driver function
if __name__ == '__main__':

    # run() method of Flask class runs the application 
    # on the local development server.
    app.run(debug=True)