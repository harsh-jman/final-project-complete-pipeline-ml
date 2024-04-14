# Use an official Python runtime as a parent image
FROM python:3.10.6

# Install Git
RUN apt-get update && \
    apt-get install -y git

# Set MongoDB environment variables
ARG MONGO_USERNAME
ARG MONGO_PASS
ARG MONGO_DBNAME
ARG MONGO_LOG_DBNAME

ENV MONGO_USERNAME $MONGO_USERNAME
ENV MONGO_PASS $MONGO_PASS
ENV MONGO_DBNAME $MONGO_DBNAME
ENV MONGO_LOG_DBNAME $MONGO_LOG_DBNAME

# Set Snowflake environment variables
ARG SNOWFLAKE_USER
ARG SNOWFLAKE_PASSWORD
ARG SNOWFLAKE_ACCOUNT
ARG SNOWFLAKE_WAREHOUSE
ARG SNOWFLAKE_DATABASE
ARG SNOWFLAKE_SCHEMA
ARG SNOWFLAKE_ROLE

ENV SNOWFLAKE_USER $SNOWFLAKE_USER
ENV SNOWFLAKE_PASSWORD $SNOWFLAKE_PASSWORD
ENV SNOWFLAKE_ACCOUNT $SNOWFLAKE_ACCOUNT
ENV SNOWFLAKE_WAREHOUSE $SNOWFLAKE_WAREHOUSE
ENV SNOWFLAKE_DATABASE $SNOWFLAKE_DATABASE
ENV SNOWFLAKE_SCHEMA $SNOWFLAKE_SCHEMA
ENV SNOWFLAKE_ROLE $SNOWFLAKE_ROLE

# Set other environment variables
ARG DBT_THREADS
ARG DBT_TYPE

ENV DBT_THREADS $DBT_THREADS
ENV DBT_TYPE $DBT_TYPE

# Set Git environment variables
ARG GIT_EMAIL
ARG GIT_NAME
ARG GIT_USERNAME
ARG GIT_TOKEN

ENV GIT_EMAIL $GIT_EMAIL
ENV GIT_NAME $GIT_NAME
ENV GIT_USERNAME $GIT_USERNAME
ENV GIT_TOKEN $GIT_TOKEN

# Configure Git and set up credentials
RUN git config --global user.email $GIT_EMAIL \
    && git config --global user.name $GIT_NAME \
    && git config --global credential.helper store \
    && echo "https://$GIT_USERNAME:$GIT_TOKEN@github.com" > ~/.git-credentials \
    && git config --global credential.helper 'store --file ~/.git-credentials'

# Setting docs
RUN git clone https://github.com/harsh-jman/harsh-jman.github.io app/DBT/target

# Set the working directory in the container for dbt
WORKDIR /root/.dbt

# Create the profiles.yml file for dbt
RUN echo "dbt_analytical_eng:\n  outputs:\n    dev:\n      account: $SNOWFLAKE_ACCOUNT\n      database: $SNOWFLAKE_DATABASE\n      password: $SNOWFLAKE_PASSWORD\n      role: $SNOWFLAKE_ROLE\n      schema: $SNOWFLAKE_SCHEMA\n      threads: $DBT_THREADS\n      type: $DBT_TYPE\n      user: $SNOWFLAKE_USER\n      warehouse: $SNOWFLAKE_WAREHOUSE\n  target: dev" > profiles.yml

# Set the working directory in the container for the app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000 to the outside world
EXPOSE $PORT

# Run gunicorn when the container launches
# Run gunicorn with specified options and timeout when the container launches
CMD ["gunicorn", "--bind", "0.0.0.0:$PORT", "--worker-class=gevent", "--worker-connections=1000", "--workers=3", "--timeout", "300", "server:app"]

