# Edit Book Feature — Implementation Roadmap

## Overview
When an admin clicks **Edit** on a book's display page, they are taken to a pre-filled edit form. After saving, they are redirected back to the book's display page.

---

## Step 1 — `genre_service.py`
Add the following function:
```python
def remove_genre_mappings_for_book(book_id):
    query_database("DELETE FROM book_genre_map WHERE book_id = %s", (book_id,))
```
> This is distinct from the existing `remove_genre_mappings` which deletes by `genre_id`. This one deletes all genre mappings for a specific book so they can be re-added cleanly on edit.

---

## Step 2 — `master_route.py`
Add three functions:

- **`get_genre_ids_for_book(book_id)`** — fetches a list of genre IDs currently mapped to a book, used to pre-check the genre checkboxes on the edit form.
- **`edit_book(book_id, cover, **kwargs)`** — calls `book_service.update_book`. Only passes `cover` into the update if a new image was actually uploaded.
- **`update_book_genres(book_id, genre_ids)`** — wipes the book's existing genre mappings and re-adds the ones submitted from the form.

---

## Step 3 — `app.py`
Add two routes:

- **`GET /edit/<book_id>`** → `edit_book_page(book_id)` — loads the book, author, series, all genres, and current genre IDs, then renders `edit_book.html`.
- **`POST /edit/<book_id>`** → `edit_book(book_id)` — processes the form, resolves author/series (adding them if new), updates the book, updates genres, then redirects to the book's display page.

Both routes are protected with `@login_required` and check that `current_user.id == 1` (Admin only).

---

## Step 4 — `edit_book.html` (new file)
A form pre-filled with the book's current data. Fields:
- Title
- Author first and last name
- Page count
- Series name and series order
- Genres (checkboxes, pre-checked based on current mappings)
- New genre (optional text input to add a genre that doesn't exist yet)
- Cover image (file upload, shows current cover as preview)

---

## Step 5 — `display_book.html`
Update the Edit button's `href` from empty to:
```html
{{ url_for('edit_book_page', book_id=displayed_book.book_id) }}
```

---

## Edge Cases Handled
- **Author doesn't exist yet** — `add_author` checks before inserting, so re-using an existing author won't create a duplicate.
- **Series doesn't exist yet** — same pattern as `add_books`, creates the series if not found.
- **No new cover uploaded** — cover field is only passed to `update_book` if a new file was provided, preserving the existing cover.
- **Genre changes** — existing mappings are wiped and re-added cleanly rather than trying to diff them.
- **Non-admin access** — both GET and POST routes check for admin and redirect with a flash message if not.