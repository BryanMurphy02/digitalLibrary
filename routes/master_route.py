
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
    return to_dict(book_service.get_all_books())

def get_authors():
    return to_dict(author_service.get_all_authors())

def get_genres():
    return to_dict(genre_service.get_all_genres())

def get_series():
    return to_dict(series_service.get_all_series())

def get_users():
    return to_dict(user_service.get_all_users())

def get_reading_calendar():
    return to_dict(reading_calendar_service.get_all_reading_calendar())



#Id get functions
#Input the name of the service and the name, returns int
def get_id(service: str, name: str):
    services = {
        "book": book_service.get_book_id, 
        "author": author_service.get_author_id, 
        "genre": genre_service.get_genre_id, 
        "series": series_service.get_series_id, 
        "user": user_service.get_user_id
    }
    if service not in services:
        raise ValueError(f"Unknown Service: {service}")
    
    get_id_func = services[service]

    if service == "author":
        parts = name.strip().split(" ")

        if len(parts) != 2:
            raise ValueError("Author name must be in 'First Last' format")

        first_name, last_name = parts
        return get_id_func(first_name, last_name)


    return get_id_func(name)



#Input the id for a table and return the row
def get_row_by_id(service: str, id: int):
    services = {
        "book": book_service.get_book_by_id, 
        "author": author_service.get_author_by_id, 
        "genre": genre_service.get_genre_by_id, 
        "series": series_service.get_series_by_id, 
        "user": user_service.get_user_by_id,
        "calendar": reading_calendar_service.get_reading_calendar_by_id
    }

    if service not in services:
        raise ValueError(f"Unknown Service: {service}")
    
    get_id_func = services[service]

    return to_dict(get_id_func(id))


#Input a row from a table and a column name, return the inputted value its looking for
#Ex: Input a row from the book table and input a column name and return the displayable value
def get_dict_value(data, column: str):

    #make data the proper format of a list if not already
    if isinstance(data, RealDictRow):
        data = to_dict(data)

    #get all the column names for "service" tables
    services = [
        book_service.get_row,
        author_service.get_row,
        genre_service.get_row,
        series_service.get_row,
        user_service.get_row,
        reading_calendar_service.get_row,
    ]

    all_keys = set()

    for service in services:
        row = service()
        if row:
            all_keys.update(to_dict(row).keys())

    #make sure the inputted column name matches one of the values in all_keys
    if column not in all_keys:
        raise ValueError(f"Unknown Column: {column}")
    
    if not data:
        return None
    return data[0].get(column)


