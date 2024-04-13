from dotenv import load_dotenv
import os
import snowflake.connector
import pandas as pd

def ingest_data_to_csv(path):
    try:
        # Connect to Snowflake using environment variables
        snowflake_conn = snowflake.connector.connect(
            user=os.environ["SNOWFLAKE_USER"],
            password=os.environ["SNOWFLAKE_PASSWORD"],
            account=os.environ["SNOWFLAKE_ACCOUNT"],
            warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
            database=os.environ["SNOWFLAKE_DATABASE"],
            schema=os.environ["SNOWFLAKE_SCHEMA"],
            role=os.environ["SNOWFLAKE_ROLE"]
        )

        # Create raw_data folder if it doesn't exist
        if not os.path.exists("staging_raw_data"):
            os.makedirs("staging_raw_data")

        # Get a cursor
        cursor = snowflake_conn.cursor()

        # Get a list of all tables in the schema
        cursor.execute("SHOW TABLES")
        tables = [table[1] for table in cursor.fetchall()]

        # Loop through each table
        for table_name in tables:
            # Construct the query to select all data from the table
            query = f"SELECT * FROM {table_name}"

            # Execute the query
            cursor.execute(query)

            # Fetch all rows
            rows = cursor.fetchall()

            # Convert rows to pandas DataFrame
            df = pd.DataFrame(rows, columns=[desc[0] for desc in cursor.description])

            # Define the path to save the CSV file
            csv_file_path = os.path.join(path, f"{table_name}.csv")

            # Write data to CSV file
            df.to_csv(csv_file_path, index=False)

            print(f"Table '{table_name}' exported to '{csv_file_path}' successfully!")

        # Close cursor
        cursor.close()

        # Close connection
        snowflake_conn.close()

    except snowflake.connector.errors.DatabaseError as e:
        # Print connection failure message
        print(f"Failed to connect to Snowflake: {e}")


# Example usage:
# Specify the path where you want to save the CSV files
# ingest_data_to_csv("your_path_here")

