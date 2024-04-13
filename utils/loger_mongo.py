import os
import pymongo
import datetime
import pytz  # Import pytz library for handling time zones

def log_message(level, message, task):
    try:
        # Construct MongoDB connection URL
        mongo_username = os.getenv("MONGO_USERNAME")
        mongo_password = os.getenv("MONGO_PASS")
        mongo_dbname = os.getenv("MONGO_LOG_DBNAME")
        mongo_url = f"mongodb+srv://{mongo_username}:{mongo_password}@test-cluster.wvpnfkn.mongodb.net/{mongo_dbname}?retryWrites=true&w=majority"

        # Connect to MongoDB
        client = pymongo.MongoClient(mongo_url)
        db = client[mongo_dbname]

        # Get the logs collection
        logs_collection = db['logs']

        # Get current UTC time
        utc_now = datetime.datetime.utcnow()

        # Define IST timezone
        ist_timezone = pytz.timezone('Asia/Kolkata')

        # Convert UTC time to IST
        ist_now = utc_now.replace(tzinfo=pytz.utc).astimezone(ist_timezone)

        # Create a new log document
        new_log = {
            'level': level,
            'message': message,
            'task': task,
            'createdAt': ist_now  # Use IST time
        }

        # Insert the log document into the database
        logs_collection.insert_one(new_log)

        return "Log saved successfully"
    except Exception as e:
        print("Error saving log:", str(e))
        return "Internal server error"

log_message("INFO", "This is an information message", "Data Ingestion")
