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
- 🐳 **Docker** – Containerized PostgreSQL for a consistent, reproducible database environment.  
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
│── docker-compose.yml # Docker configuration for PostgreSQL
│── .env.example       # Environment variable template
│── /db                # init.sql schema script for Docker
│── /database          # SQL scripts, migrations, ERD diagrams
│── /services          # Model layer: database access methods (psycopg2)
│── /templates         # View layer: HTML templates for Flask
│── /static            # CSS, JS, images 
```

## Docker

The PostgreSQL database runs inside a Docker container, keeping the database environment isolated, consistent, and reproducible across machines. The Flask application runs locally and connects to the containerized database.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

### How It Works

The `docker-compose.yml` file defines the PostgreSQL container. A named Docker volume stores the database files independently of the container, meaning data persists even if the container is stopped or removed. When the container is started for the first time with an empty volume, it automatically runs `db/init.sql` to create all tables, enums, constraints, and relationships.

### Environment Variables

Database credentials and connection details are managed through a `.env` file that is never committed to the repository. Copy the example file and fill in your own values:

```bash
cp .env.example .env
```

`.env.example`:
```
DB_HOST=localhost
DB_PORT=5433
DB_NAME=digital_library_docker
DB_USER=postgres
DB_PASSWORD=
```

### Starting the Database

```bash
# Start the PostgreSQL container in the background
docker compose up -d

# Verify the container is running
docker compose ps

# Stop the container (data is preserved in the volume)
docker compose down

# Stop the container and delete all data (full reset)
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

After setting up the project (see Installation & Setup), users can:

1. **Run the Application**
```bash
# Create virtual environment (if applicable)
python3 -m venv venv

# Activate your virtual environment (if applicable)
# Example for Python venv:
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows

# Install from requirements
pip install -r requirements.txt

# Start the database container
docker compose up -d

# Run Flask app
python app.py

# Run a specific file within project
python -m folder_name.file_name

# Update the requirements file
pip freeze > requirements.txt
```

## Roadmap
🚧 Work in progress!  
The roadmap will include upcoming features, enhancements, and stretch goals as development continues. Stay tuned for updates.