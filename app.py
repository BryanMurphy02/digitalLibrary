# Importing flask module in the project is mandatory
# An object of Flask class is our WSGI application.
from flask import Flask, render_template
from flask_login import LoginManager

from routes import master_route, user_route

# Flask constructor takes the name of 
# current module (__name__) as argument.
app = Flask(__name__)

# Creating the login object
login_manager = LoginManager()
login_manager.init_app(app)

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
def profile():
    return render_template("profile.html")

@app.route('/reading_calendar')
def reading_calendar():
    return render_template("reading_calendar.html")

@app.route('/login')
def login():
    return render_template("login.html")

@app.route('/register')
def register():
    return render_template("register.html")




# Login managar getting the user_id as a string
@login_manager.user_loader
def load_user(user_id):
    return user_route.get_user_by_id(user_id)

# main driver function
if __name__ == '__main__':

    # run() method of Flask class runs the application 
    # on the local development server.
    app.run(debug=True)