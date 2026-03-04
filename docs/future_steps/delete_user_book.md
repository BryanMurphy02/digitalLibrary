Edits to html

<div class="book-card trash-card">
    <a href="{{ url_for('display_book', book_id=book.book_id) }}" class="book-card-link">
        <div class="book-cover">
            <img src="{{ url_for('static', filename=book.book_cover) }}" alt="{{ book.book_title }}">
        </div>
        <div class="book-info">
            <p class="book-title">{{ book.book_title }}</p>
            <p class="book-author">{{ book.author_first_name }} {{ book.author_last_name }}</p>
        </div>
    </a>
    <div class="trash-actions">
        <a href="{{ url_for('display_book', book_id=book.book_id) }}" class="trash-btn restore-btn">Open</a>
        <form action="{{ url_for('remove_from_library', book_id=book.book_id) }}" method="POST">
            <button type="submit" class="trash-btn delete-btn">Delete</button>
        </form>
    </div>
</div>

Edits to css:

.book-card-link {
    display: block;
    padding-bottom: 0;
}