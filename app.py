# Importing flask module in the project is mandatory
# An object of Flask class is our WSGI application.
from flask import Flask, render_template
from flask import request, redirect, url_for, flash
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
import uuid
import os

from routes import master_route, user_route


load_dotenv(override=False)

# Flask constructor takes the name of 
# current module (__name__) as argument.
app = Flask(__name__)

app.secret_key = os.environ.get("SECRET_KEY")


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
    library_table = master_route.get_library_table()
    return render_template("library.html", library_table=library_table)

@app.route('/add_to_library/<int:book_id>', methods=['POST'])
def add_to_library(book_id):
    user_id = current_user.id
    master_route.add_user_book(user_id, book_id)
    return redirect(url_for('profile'))

@app.route('/delete/<int:book_id>', methods=['POST'])
def soft_delete(book_id):
    master_route.soft_book_delete(book_id)
    return redirect(url_for('library'))

@app.route('/trash')
def trash():
    trash_table = master_route.get_trash()
    return render_template("trash.html", trash_table=trash_table)

@app.route('/restore/<int:book_id>', methods=['POST'])
def restore(book_id):
    master_route.restore_book(book_id)
    return redirect(url_for('trash'))

@app.route('/hard_delete/<int:book_id>', methods=['POST'])
def hard_delete(book_id):
    master_route.hard_book_delete(book_id)
    return redirect(url_for('trash'))

@app.route('/book/<int:book_id>')
def display_book(book_id):
    displayed_book = master_route.get_book_display(book_id)
    return render_template("display_book.html", displayed_book=displayed_book)

@app.route('/display_user_book')
def display_user_book():
    return render_template("display_user_book.html")

@app.route('/remove_user_book')
def remove_user_book():
    return render_template("display_user_book.html")

@app.route('/edit/<int:book_id>', methods=['GET'])
@login_required
def edit_book_page(book_id):
    if current_user.id != 1:
        flash("You do not have permission to edit books.")
        return redirect(url_for('display_book', book_id=book_id))

    book = master_route.get_row_by_id("book", book_id)
    author = master_route.get_row_by_id("author", book['author_id'])
    series = master_route.get_row_by_id("series", book['series_id']) if book['series_id'] else None
    all_genres = master_route.get_genres()
    current_genre_ids = master_route.get_genre_ids_for_book(book_id)

    return render_template(
        "edit_book.html",
        book=book,
        author=author,
        series=series,
        all_genres=all_genres,
        current_genre_ids=current_genre_ids
    )


@app.route('/edit/<int:book_id>', methods=['POST'])
@login_required
def edit_book(book_id):
    if current_user.id != 1:
        flash("You do not have permission to edit books.")
        return redirect(url_for('display_book', book_id=book_id))

    title = request.form.get('title')
    author_first_name = request.form.get('author_first_name')
    author_last_name = request.form.get('author_last_name')
    page_count = request.form.get('page_count') or None
    series_name = request.form.get('series_name') or None
    series_order = request.form.get('series_order') or None
    genre_ids = request.form.getlist('genres')
    new_genre = request.form.get('new_genre') or None

    # handle cover upload
    cover_file = request.files.get('cover') or None
    cover_path = None
    if cover_file and cover_file.filename:
        filename = secure_filename(cover_file.filename)
        ext = filename.rsplit('.', 1)[1]
        filename = f"{uuid.uuid4()}.{ext}"
        cover_path = f"images/books/{filename}"
        cover_file.save(os.path.join("static", cover_path))

    # author
    author_id = master_route.add_author(author_first_name, author_last_name)

    # series
    series_id = None
    if series_name:
        series_id = master_route.get_id("series", series_name)
        if series_id is None:
            series_id = master_route.add_series(series_name, author_id)

    # update book
    master_route.edit_book(
        book_id,
        title=title,
        author_id=author_id,
        page_count=page_count,
        series_id=series_id,
        series_order=series_order,
        cover=cover_path
    )

    # update genres by wiping and re-adding
    if new_genre:
        new_genre_id = master_route.add_genre(new_genre)
        genre_ids.append(new_genre_id)

    master_route.update_book_genres(book_id, [int(g) for g in genre_ids])

    flash("Book updated successfully!")
    return redirect(url_for('display_book', book_id=book_id))

@app.route('/profile')
@login_required
def profile():
    user_data = master_route.get_row_by_id("user", current_user.id)
    user_books = master_route.get_user_books(current_user.id)
    return render_template("profile.html", user_data=user_data, user_books=user_books)




@app.route('/reading_calendar')
@login_required
def reading_calendar():
    return render_template("reading_calendar.html")

@app.route('/add_books', methods=['GET', 'POST'])
@login_required
def add_books():

    if request.method == 'POST':
        # required
        book_title = request.form.get('book_title')
        author_first_name = request.form.get('author_first_name')
        author_last_name = request.form.get('author_last_name')
        

        if not book_title or not author_first_name or not author_last_name:
            flash("Title and author fields are required.")
            return redirect(url_for('add_books'))

        # optional
        page_count = request.form.get('page_count') or None
        series_name = request.form.get('series_name') or None
        series_order = request.form.get('series_order') or None
        genre_ids = request.form.getlist('genres')
        new_genre = request.form.get('new_genre') or None

        # book cover processing
        cover_file = request.files.get('cover') or None
        cover_path = None

        if cover_file and cover_file.filename:
            filename = secure_filename(cover_file.filename)
            ext = filename.rsplit('.', 1)[1]
            filename = f"{uuid.uuid4()}.{ext}"
            cover_path = f"images/books/{filename}"
            cover_file.save(os.path.join("static", cover_path))

        # get author_id or add the author
        author_id = master_route.add_author(author_first_name, author_last_name)

        # series logic
        series_id = None
        if series_name:
            series_id = master_route.get_id("series", series_name)
            if series_id is None:
                series_id = master_route.add_series(series_name, author_id)

        # adding to database
        book_id = master_route.add_book(book_title, author_id, page_count, cover_path, series_id, series_order)

        # genre logic
        if new_genre:
            new_genre_id = master_route.add_genre(new_genre)
            genre_ids.append(new_genre_id)

        # add to book_genre_map
        for genre_id in genre_ids:
            master_route.add_genre_mapping(book_id, int(genre_id))

        flash("Book added successfully!")
        return redirect(url_for('library'))

    genres = master_route.get_genres()
    return render_template("add_books.html", genres=genres)



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
    # host added when containing flask with docker
    app.run(host="0.0.0.0", debug=True)