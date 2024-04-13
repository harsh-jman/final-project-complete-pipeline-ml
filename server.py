import os
import shutil
import logging
import time
from flask import Flask, request, jsonify, send_file
from dotenv import load_dotenv
from flask_cors import CORS
from model.train import training
from model.output_model import output
from utils.get_eda import generate_eda_report
from utils.data_ingestion_pipeline import connect_mongodb, connect_snowflake, get_data_from_mongodb, ingest_data_to_snowflake, empty_csv_folder
from utils.dbt_triggers import dbtDocsGenerate, dbtRun
from utils.loger_mongo import log_message
from utils.git_dbt_docs_push import commit_files_to_repo

load_dotenv()

logging.basicConfig(filename='api_logs.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)
CORS(app, origins='*')

# ML endpoint
@app.route('/', methods=['GET'])
def ml_endpoint():
    logging.info("Received request to ML endpoint")
    return jsonify({'message': 'Machine Learning endpoint'}), 200

# Train endpoint
@app.route('/train', methods=['GET'])
def train_endpoint():
    try:
        start_time = time.time()
        res = training('data/artifact/synthetic_data.csv', 'text', 'resources/embedding_index.npz')
        end_time = time.time()
        running_time = round(end_time - start_time, 2)
        response = {'message': 'Train Success', 'TimeTaken': running_time, 'status': 'success'}
        log_message("Training", "Model Re-Training Success", 'ML Training')
        logging.info("Training successful. Time taken: %s seconds", running_time)
        return jsonify(response), 200
    except Exception as e:
        logging.error("Error occurred during training: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred during training: {str(e)}"
        }
        return jsonify(response), 500

# Output endpoint
@app.route('/output', methods=['POST'])
def output_endpoint():
    try:
        data = request.get_json()
        text = data.get('text')
        temperature = data.get('temperature')
        count = data.get('count')
        dis = output(text, float(temperature), int(count))
        response = {'text': text, 'temperature': temperature, 'data': dis}
        logging.info("Output generated successfully for text: %s", text)
        return jsonify(response), 200
    except Exception as e:
        logging.error("Error occurred during output generation: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred during output generation: {str(e)}"
        }
        return jsonify(response), 500

@app.route('/ingest', methods=['GET'])
def ingest_data():
    try:
        start_time = time.time()
        mongo_db, mongo_client = connect_mongodb()
        snowflake_conn = connect_snowflake()

        if mongo_db is None or snowflake_conn is None:
            return "Failed to establish connections", 500

        get_data_from_mongodb(mongo_db, mongo_client)
        ingest_data_to_snowflake(snowflake_conn)
        empty_csv_folder()

        end_time = time.time()
        running_time = round(end_time - start_time, 2)
        response = {
            "status": "success",
            "message": "Data ingestion successful",
            "TimeTaken": running_time
        }
        log_message("Data Ingestion", "Ingestion Success", 'Data Ingestion')
        logging.info("Data ingestion successful. Time taken: %s seconds", running_time)
        return jsonify(response), 200
    except Exception as e:
        logging.error("Error occurred during data ingestion: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred during data ingestion: {str(e)}"
        }
        return jsonify(response), 500

@app.route('/dbtRun', methods=['GET'])
def dbt_run():
    try:
        start_time = time.time()
        dbtRun()
        log_message("DBT Run", "DBT Model Success", 'DBT Run')
        end_time = time.time()
        running_time = round(end_time - start_time, 2)
        response = {
            "status": "success",
            "message": "dbt Run successful",
            "TimeTaken": running_time
        }
        logging.info("DBT Run successful. Time taken: %s seconds", running_time)
        return jsonify(response), 200
    except Exception as e:
        logging.error("Error occurred during dbt Run: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred during dbt Run: {str(e)}"
        }
        return jsonify(response), 500

@app.route('/getEDA', methods=['GET'])
def eda_endpoint():
    try:
        input_file = "data/processed/eda.csv"
        output_file = "resources/eda_report.html"
        start_time = time.time()
        generate_eda_report(input_file, output_file)
        log_message("INFO", "EDA report generated successfully", "EDA Report")
        end_time = time.time()
        running_time = round(end_time - start_time, 2)
        response = {
            "status": "success",
            "message": "EDA report generated successfully",
            "TimeTaken": running_time
        }
        logging.info("EDA report generated successfully. Time taken: %s seconds", running_time)
        return jsonify(response), 200
    except Exception as e:
        logging.error("Error occurred during EDA report generation: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred during EDA report generation: {str(e)}"
        }
        return jsonify(response), 500

@app.route('/dbtDocsGenerate', methods=['GET'])
def dbt_docs_generate():
    try:
        start_time = time.time()
        dbtDocsGenerate()
        log_message("INFO", "DBT docs generated successfully", "DBT Docs")
        commit_files_to_repo()
        end_time = time.time()
        running_time = round(end_time - start_time, 2)
        response = {
            "status": "success",
            "message": "DBT docs generated successfully",
            "TimeTaken": running_time
        }
        logging.info("DBT docs generated successfully. Time taken: %s seconds", running_time)
        return jsonify(response), 200
    except Exception as e:
        logging.error("Error occurred during DBT docs generation: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred during DBT docs generation: {str(e)}"
        }
        return jsonify(response), 500

@app.route('/getEDAfile', methods=['GET'])
def eda_file_endpoint():
    try:
        file_path = "resources/eda_report.html"
        return send_file(file_path, as_attachment=True), 200
    except Exception as e:
        logging.error("Error occurred while generating EDA report file: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred while generating EDA report file: {str(e)}"
        }
        return jsonify(response), 500

@app.route('/dbtDocsGenerateFile', methods=['GET'])
def dbt_docs_generate_file():
    try:
        file_path = "resources/index.html"
        return send_file(file_path, as_attachment=True), 200
    except Exception as e:
        logging.error("Error occurred while generating DBT docs file: %s", str(e))
        response = {
            "status": "error",
            "message": f"Error occurred while generating DBT docs file: {str(e)}"
        }
        return jsonify(response), 500

if __name__ == '__main__':
    app.run(debug=True)
