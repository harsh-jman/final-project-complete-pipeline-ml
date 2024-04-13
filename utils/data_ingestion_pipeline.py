# utils.py

import os
import pymongo
import snowflake.connector
import pandas as pd
import logging

def empty_csv_folder():
    folder_path = 'staging_raw_data'
    if os.path.exists(folder_path):
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)
            try:
                if os.path.isfile(file_path):
                    os.unlink(file_path)
            except Exception as e:
                logging.error(f"Error occurred while deleting file {file_path}: {str(e)}")

def connect_mongodb():
    try:
        mongo_connection_string = (
            f"mongodb+srv://{os.environ['MONGO_USERNAME']}:"
            f"{os.environ['MONGO_PASS']}@"
            f"test-cluster.wvpnfkn.mongodb.net/"
            +"?retryWrites=true&w=majority&appName=test-cluster"
        )
        mongo_client = pymongo.MongoClient(mongo_connection_string)
        mongo_db = mongo_client[os.environ['MONGO_DBNAME']]
        return mongo_db,mongo_client
    except pymongo.errors.ConnectionFailure as e:
        print(f"Failed to connect to MongoDB Atlas: {e}")
        return None

def connect_snowflake():
    try:
        snowflake_conn = snowflake.connector.connect(
            user=os.environ["SNOWFLAKE_USER"],
            password=os.environ["SNOWFLAKE_PASSWORD"],
            account=os.environ["SNOWFLAKE_ACCOUNT"],
            warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
            database=os.environ["SNOWFLAKE_DATABASE"],
            schema=os.environ["SNOWFLAKE_SCHEMA"],
            role=os.environ["SNOWFLAKE_ROLE"]
        )
        return snowflake_conn
    except snowflake.connector.errors.DatabaseError as e:
        print(f"Failed to connect to Snowflake: {e}")
        return None

def get_data_from_mongodb(mongo_db,mongo_client):
    ## Mongo to Stage

    # Create raw_data folder if it doesn't exist
    if not os.path.exists("staging_raw_data"):
        os.makedirs("staging_raw_data")

    # Iterate over each collection
    for collection_name in mongo_db.list_collection_names():
        # Retrieve data from collection
        collection_data = list(mongo_db[collection_name].find())
        
        # Convert data to DataFrame
        df = pd.DataFrame(collection_data)
        
        # Write DataFrame to CSV file
        csv_file_path = f"staging_raw_data/{collection_name}.csv"
        df.to_csv(csv_file_path, index=False)
        print(f"Data from collection '{collection_name}' written to '{csv_file_path}'")



    # Close MongoDB connection
    mongo_client.close()


def ingest_data_to_snowflake(snowflake_conn):
    ## Ingest Into Snowflake

    # Create staging_raw_data folder if it doesn't exist
    if not os.path.exists("staging_raw_data"):
        print("No data to process. Exiting.")
        exit()

    # Iterate over each CSV file in the staging_raw_data folder
    for filename in os.listdir("staging_raw_data"):
        if filename.endswith(".csv"):
            # Extract table name from filename (remove .csv extension)
            table_name = os.path.splitext(filename)[0]
            
            # Read CSV file into DataFrame
            df = pd.read_csv(f"staging_raw_data/{filename}")
            
            # Replace NaN values with empty strings
            df = df.fillna('')
            
            # Convert all data to string
            df = df.astype(str)
            

            # Create table in Snowflake if it doesn't exist
            snowflake_cursor = snowflake_conn.cursor()
            
            snowflake_cursor.execute(f"DROP TABLE IF EXISTS {table_name}")
            
            create_table_query = f"CREATE TABLE {table_name} ("
            for column in df.columns:
                create_table_query += f'"{column}" VARCHAR,'
            create_table_query = create_table_query[:-1] + ")"  # Remove trailing comma
            snowflake_cursor.execute(create_table_query)
            
            # Prepare INSERT INTO statement
            insert_query = f"INSERT INTO {table_name} VALUES ({','.join(['%s'] * len(df.columns))})"
            
            # Convert DataFrame to list of tuples (rows)
            rows = [tuple(row) for row in df.itertuples(index=False)]
            
            # Execute bulk insert
            snowflake_cursor.executemany(insert_query, rows)
            snowflake_cursor.close()
            
            print(f"Data from '{filename}' inserted into '{table_name}' table in Snowflake.")

    # Commit the transaction
    snowflake_conn.commit()

    # Close Snowflake connection
    snowflake_conn.close()
