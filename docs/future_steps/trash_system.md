# Soft Delete / Trash System Implementation

## Overview
Instead of permanently deleting books, mark them as deleted using a `deleted_at` timestamp.
- `NULL` = active book
- Has a value = trashed book

The admin account can then restore or permanently delete trashed books.

---

## Step 1 — Add `deleted_at` Column to `books`

```sql
ALTER TABLE public.books 
ADD COLUMN deleted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL;
```

---

## Step 2 — Update the `library_table` View

Add a `WHERE deleted_at IS NULL` filter so trashed books don't appear in normal queries.

```sql
CREATE OR REPLACE VIEW public.library_table AS
  SELECT 
    books.id AS book_id,
    books.title AS book_title,
    books.cover AS book_cover,
    author.first_name AS author_first_name,
    author.last_name AS author_last_name
  FROM public.books
  JOIN public.author ON books.author_id = author.id
  WHERE books.deleted_at IS NULL;
```

---

## Step 3 — Update the `book_display` View

Same filter applied to the more detailed display view.

```sql
CREATE OR REPLACE VIEW public.book_display AS
  SELECT 
    books.id AS book_id,
    books.title AS book_title,
    books.cover AS book_cover,
    books.page_count,
    books.series_order,
    author.first_name AS author_first_name,
    author.last_name AS author_last_name,
    series.name AS series_name,
    string_agg(genre.name, ', ') AS genres
  FROM public.books
  JOIN public.author ON books.author_id = author.id
  LEFT JOIN public.series ON books.series_id = series.id
  LEFT JOIN public.book_genre_map ON books.id = book_genre_map.book_id
  LEFT JOIN public.genre ON book_genre_map.genre_id = genre.id
  WHERE books.deleted_at IS NULL
  GROUP BY books.id, books.title, books.cover, books.page_count, 
           books.series_order, author.first_name, author.last_name, series.name;
```

---

## Step 4 — Create a `trash` View (Admin Only)

Lets the admin see all trashed books.

```sql
CREATE VIEW public.trash AS
  SELECT * FROM public.books 
  WHERE deleted_at IS NOT NULL;
```

---

## Step 5 — Trash / Restore / Permanently Delete Queries

**Trash a book (soft delete):**
```sql
UPDATE public.books 
SET deleted_at = NOW() 
WHERE id = <book_id>;
```

**Restore a book:**
```sql
UPDATE public.books 
SET deleted_at = NULL 
WHERE id = <book_id>;
```

**Permanently delete a book (empty trash):**
```sql
BEGIN;
  DELETE FROM public.book_genre_map WHERE book_id = <book_id>;
  UPDATE public.users SET favorite_book = NULL WHERE favorite_book = <book_id>;
  DELETE FROM public.books WHERE id = <book_id>;
COMMIT;
```

**Auto-purge books trashed more than 30 days ago (optional scheduled job):**
```sql
BEGIN;
  DELETE FROM public.book_genre_map 
  WHERE book_id IN (
    SELECT id FROM public.books WHERE deleted_at < NOW() - INTERVAL '30 days'
  );
  UPDATE public.users SET favorite_book = NULL 
  WHERE favorite_book IN (
    SELECT id FROM public.books WHERE deleted_at < NOW() - INTERVAL '30 days'
  );
  DELETE FROM public.books 
  WHERE deleted_at < NOW() - INTERVAL '30 days';
COMMIT;
```

---

## Notes
- `user_books` and `reading_calendar` both have `ON DELETE CASCADE`, so they are preserved during soft deletion and will be restored along with the book automatically.
- Make sure any new views or queries added in the future also include `WHERE deleted_at IS NULL` to prevent trashed books from leaking through.
- The `user_book_library` view is built on top of `library_table`, so it will inherit the `deleted_at` filter automatically once Step 2 is done — no extra changes needed there.