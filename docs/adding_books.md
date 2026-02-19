# Data Entry Guide

A reference for manually adding books and genres to the database using the service layer methods.

---

## Adding a Non-Series Book

**1. Add the book**

```python
add_book(
    book_title="",
    author_first_name="",
    author_last_name="",
    cover=optional,
    page_count=optional
)
```

**2. Link the book to its genres**

```python
add_genres_to_book(get_book_id("Book Name"), "Genre1", "Genre2", "Genre3")
```

---

## Adding a Series Book

**1. Add the book**

```python
add_book(
    book_title="",
    author_first_name="",
    author_last_name="",
    cover=optional,
    page_count=optional,
    series_id=get_series_id("Name of Series", add_author("First Name", "Last Name")),
    series_order=
)
```

> `add_author` is used here because it returns the existing `author_id` if the author is already in the database, avoiding duplicates.

**2. Link the book to its genres**

```python
add_genres_to_book(get_book_id("Book Name"), "Genre1", "Genre2", "Genre3")
```

---

## Adding Genres

Use `get_genre_id(name)` rather than inserting a genre directly. This method checks whether the genre already exists in the database before creating it, preventing duplicates.

```python
get_genre_id("Fantasy")
```