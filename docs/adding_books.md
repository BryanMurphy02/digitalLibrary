# Adding a Book to the Database

## Overview

When inserting a new book into the database, multiple tables must be populated in a specific order. Because the `books` table references other tables via foreign keys, dependent records must exist before the book itself can be inserted. The sections below outline each step in the required sequence.

---

## Step 1: Author

The `books` table contains a required `author_id` foreign key that references the `author` table. Before inserting a book, verify that the author already exists. If no matching record is found, insert the author first.

```sql
-- Check if the author already exists
SELECT id FROM public.author
WHERE first_name = 'Terry' AND last_name = 'Pratchett';

-- If no record is returned, insert the author
INSERT INTO public.author (first_name, last_name)
VALUES ('Terry', 'Pratchett')
RETURNING id;
```

**Note:** Retain the returned `id` value, as it is required in subsequent steps.

---

## Step 2: Series *(if applicable)*

The `books` table contains an optional `series_id` foreign key that references the `series` table. If the book is part of a series, verify that the series record exists before proceeding. If no matching record is found, insert the series using the `author_id` obtained in Step 1.

```sql
-- Check if the series already exists
SELECT id FROM public.series
WHERE name = 'Discworld';

-- If no record is returned, insert the series
INSERT INTO public.series (name, author_id)
VALUES ('Discworld', <author_id>)
RETURNING id;
```

**Note:** If the book is a standalone title, this step can be skipped. Set `series_id` and `series_order` to `NULL` in Step 3.

---

## Step 3: Book

Once the author and series records are confirmed or created, the book record can be inserted into the `books` table.

```sql
INSERT INTO public.books (title, cover, page_count, series_id, author_id, series_order)
VALUES (
    'The Colour of Magic',
    'images/books/the_colour_of_magic.jpg',
    288,
    <series_id>,      -- NULL if standalone
    <author_id>,
    1                 -- NULL if standalone
)
RETURNING id;
```

**Note:** Retain the returned `id` value, as it is required for genre mapping in Step 4.

---

## Step 4: Genres

Genres are associated with books through the `book_genre_map` junction table. Before creating the mapping, verify that all required genre records exist in the `genre` table. Insert any genres that are not already present, then create the mapping entries.

```sql
-- Retrieve all existing genres
SELECT id, name FROM public.genre;

-- If a required genre does not exist, insert it
INSERT INTO public.genre (name)
VALUES ('Satire')
RETURNING id;

-- Map each genre to the book
INSERT INTO public.book_genre_map (book_id, genre_id)
VALUES
    (<book_id>, <genre_id_1>),
    (<book_id>, <genre_id_2>);
```

---

## Execution Order Reference

The following table summarizes the required insertion order and the reason each step must precede the next.

| Step | Table | Reason |
|------|-------|--------|
| 1 | `author` | `books.author_id` is a required foreign key |
| 2 | `series` | `books.series_id` is an optional foreign key |
| 3 | `books` | Depends on `author` and `series` records existing |
| 4 | `genre` | Must exist prior to creating genre mappings |
| 4 | `book_genre_map` | Depends on `books` and `genre` records existing |

---

## Constraints and Considerations

**Duplicate Authors** — Always query the `author` table before inserting a new record. Inserting duplicate author entries will result in data inconsistency, as multiple author IDs would exist for the same individual.

**`series_order` Uniqueness** — A `UNIQUE` constraint exists on the `(series_id, series_order)` column pair. No two books within the same series may share the same position number.

**`series.author_id`** — The `series` table stores its own `author_id` reference. This value must match the `author_id` used when inserting the associated book records.

**Genre Reusability** — Genre records such as `Fiction` and `Fantasy` are shared across all books. Always verify a genre does not already exist before inserting a new record to prevent duplicate entries.