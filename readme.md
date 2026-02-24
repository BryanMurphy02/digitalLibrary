# Digital Library
A Goodreads-inspired web application built to practice backend development and database design.  
Digital Library allows users to explore books with detailed information, add them to personal libraries, track their reading progress, rate titles, and record notes. 

## Table of Contents
- [Features](#features)
- [Tech Stack / Built With](#tech-stack--built-with)
- [Architecture](#architecture)
- [Installation & Setup](#installation--setup)
- [Docker](#docker)
- [Usage](#usage)
- [Roadmap](#roadmap)

## Features

- 📚 **Book Catalog** – Browse books with detailed information including title, author, genre, page count, and series.  
- 🗂 **Personal Library** – Add books to a personal library to track your collection.  
- ⏳ **Reading Progress** – Track whether a book is "To Be Read," "Currently Reading," or "Completed."  
- 🗓️ **Reading Calendar** – Track the amount of pages read in a day with specific books.  
- ⭐ **Ratings & Reviews** – Rate books and leave personal notes or reflections.  
- 📝 **Book Notes** – Save quotes, ideas, or thoughts tied to specific books.  
- 👥 **User Accounts (Planned)** – Secure login system to manage individual libraries.  
- 🔍 **Search & Filter (Planned)** – Quickly find books by title, author, or genre.  

## Tech Stack / Built With

- 🐘 **PostgreSQL** – Relational database to store book, user, and library data.  
- 🐳 **Docker** – Containerized PostgreSQL and Flask app for a consistent, reproducible environment.  
- 🔗 **psycopg2** – Python library for connecting and interacting with PostgreSQL.  
- 🐍 **Python** – Core backend logic including data access methods (GET/SET).  
- 🌐 **Flask** – Lightweight Python web framework for serving the application.  
- 🎨 **HTML & CSS** – Frontend structure and styling for displaying content.  
- ⚡ **JavaScript (minimal)** – Small enhancements for interactivity.  

## Architecture

The project follows a **Model-View-Controller (MVC)** style architecture to keep the database, backend logic, and frontend display separated and maintainable.  

- 🗄 **Model Layer (Service Layer)**  
  - Handles all interactions with the PostgreSQL database.  
  - Uses **psycopg2** to run queries and return data.  
  - Provides clean `GET` and `SET` methods for the rest of the application.  

- 🔧 **Controller Layer (Routes Layer)**  
  - Implemented with **Flask routes**.  
  - Calls the service layer to fetch or update data.  
  - Converts responses into **JSON format** so the frontend can consume them.  

- 🎨 **View Layer (Frontend)**  
  - Parses JSON data returned from the controller.  
  - Displays book details, libraries, and user interactions using **HTML & CSS**.  
  - Uses minimal **JavaScript** to enhance interactivity.  

### Project Structure

```bash
project-root/
│── app.py             # Flask entry point (controllers / routes)
│── database.py        # Psycopg2 setup
│── requirements.txt   # Python dependencies
│── Dockerfile         # Docker image definition for the Flask app
│── docker-compose.yml # Docker configuration for Flask + PostgreSQL
│── .env.example       # Environment variable template
│── /db                # init.sql schema script for Docker
│── /database          # SQL scripts, migrations, ERD diagrams
│── /services          # Model layer: database access methods (psycopg2)
│── /templates         # View layer: HTML templates for Flask
│── /static            # CSS, JS, images 
```

## Installation & Setup

Everything runs inside Docker — no need to install Python, PostgreSQL, or any dependencies manually on your machine.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- [Git](https://git-scm.com/) installed

### Step 1 — Clone the repository

```bash
git clone <your-repo-url>
cd digitalLibrary
```

### Step 2 — Create your `.env` file

The `.env` file holds all secrets and environment variables. It is never committed to the repository. Copy the example file to create your own:

```bash
cp .env.example .env
```

Then open `.env` and fill in your values:

```
DB_HOST=localhost
DB_PORT=5433
DB_NAME=digital_library_docker
DB_USER=postgres
DB_PASSWORD=your_password_here

SECRET_KEY=your_generated_secret_key_here

ADMIN_USERNAME=Admin
ADMIN_EMAIL=useradmin@gmail.com
ADMIN_PASSWORD=useradmin!@#$
```

### Step 3 — Generate a secret key

The `SECRET_KEY` is used by Flask to securely sign session cookies. Generate a strong random key by running the following in your terminal:

| OS | Command |
|---|---|
| Windows / Linux | `python -c "import secrets; print(secrets.token_hex(32))"` |
| Mac | `python3 -c "import secrets; print(secrets.token_hex(32))"` |

Copy the output and paste it as the value for `SECRET_KEY` in your `.env` file.

### Step 4 — Build and start the application

```bash
docker compose up --build
```

This will:
- Pull the PostgreSQL image
- Build the Flask application image from the `Dockerfile`
- Run `db/init.sql` to create all tables, enums, and seed data (including the admin account) on first startup
- Start both containers

Once running, open your browser and go to `http://localhost:5000`.

To run in the background instead:

```bash
docker compose up --build -d
```

---

## Docker

The application runs fully inside Docker — the PostgreSQL database and the Flask web app each run in their own container, orchestrated by `docker-compose.yml`.

### How It Works

The `docker-compose.yml` file defines both containers. A named Docker volume stores the database files independently of the container, meaning data persists even if the container is stopped or removed. When the database container is started for the first time with an empty volume, it automatically runs `db/init.sql` to create all tables, enums, constraints, relationships, and seed data.

### Environment Variables

All credentials and secrets are managed through a `.env` file that is never committed to the repository. See [Installation & Setup](#installation--setup) for how to create it.

### Common Docker Commands

```bash
# Build and start all containers
docker compose up --build

# Start in the background (detached mode)
docker compose up -d

# View running containers
docker compose ps

# View live logs
docker compose logs -f

# Stop all containers (data is preserved)
docker compose down

# Stop all containers and delete all data (full reset)
docker compose down -v
```

### Connecting with pgAdmin

To inspect the database visually using pgAdmin, register a new server with the following settings:

- **Host:** `localhost`
- **Port:** `5433`
- **Database:** `digital_library_docker`
- **Username:** `postgres`
- **Password:** *(your value from `.env`)*

Port `5433` is used to avoid conflicts with any locally installed PostgreSQL instance running on the default port `5432`.

## Usage

Once the application is running via `docker compose up`, visit `http://localhost:5000` in your browser.

The admin account is automatically created when the database is initialized. Use the credentials from your `.env` file to log in as admin.

For development reference:

```bash
# Update the requirements file after installing new packages locally
pip freeze > requirements.txt

# Run a specific file within the project
python -m folder_name.file_name
```

## Roadmap
🚧 Work in progress!  
The roadmap will include upcoming features, enhancements, and stretch goals as development continues. Stay tuned for updates.

## Resources & Documentation

- [Flask](https://flask.palletsprojects.com/en/stable/) – Web framework used to build and serve the application
- [psycopg2](https://www.psycopg.org/docs/) – PostgreSQL adapter for Python
- [Flask-Login](https://flask-login.readthedocs.io/en/latest/) – User session management for Flask
- [PostgreSQL](https://www.postgresql.org/docs/) – Database documentation and SQL reference
- [Docker](https://docs.docker.com/) – Container platform documentation
- [Docker Compose](https://docs.docker.com/compose/) – Multi-container Docker application documentation
