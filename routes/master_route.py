
from services import book_service, author_service, genre_service, reading_calendar_service, series_service, user_service
from psycopg2.extras import RealDictRow


def to_dict(data):
    """
    Convert RealDictRow(s) or lists of RealDictRows to Python dict(s).
    Can also handle plain dict, list, int, float, str.
    """
    # isinstance checks the object passed in against a type. Returns true if so
    if isinstance(data, RealDictRow):
        return dict(data)
    elif isinstance(data, list):
        return [dict(item) if isinstance(item, RealDictRow) else item for item in data]
    else:
        return data


def get_books():
    rows = book_service.get_all_books()
    return to_dict(rows)

def get_authors():
    rows = author_service.get_all_authors()
    return to_dict(rows)

def get_genres():
    rows = genre_service.get_all_genres()
    return to_dict(rows)

def get_series():
    rows = series_service.get_all_series()
    return to_dict(rows)

def get_users():
    rows = user_service.get_all_users()
    return to_dict(rows)

def get_reading_calendar():
    rows = reading_calendar_service.get_all_reading_calendar()
    return to_dict(rows)