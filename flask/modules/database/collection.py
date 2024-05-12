import datetime
from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017")
db = client.image_prediction
image_details = db.imageData

def addNewImage(image_url, class_name):
    """
    Adds a new image entry to the database.
    :param image_url: URL of the image
    :param class_name: Name of the detected class for the image
    """
    try:
        image_details.insert_one({
            'image_url': image_url,
            'class_name': class_name,  # Storing class name
            'timestamp': datetime.datetime.now()  # Current timestamp
        })
        return True
    except Exception as e:
        print(f"An error occurred: {e}")
        return False


def getAllImages():
    """
    Retrieves all image entries from the database.
    """
    try:
        data = image_details.find({}, {'_id': 0})
        return list(data)
    except Exception as e:
        print(f"An error occurred: {e}")
        return []

def close_connection():
    """
    Closes the MongoDB client connection.
    """
    client.close()