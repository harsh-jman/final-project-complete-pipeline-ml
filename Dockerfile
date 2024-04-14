# Use an official Python runtime as a parent image
FROM python:3.10.6

# Install Git
RUN apt-get update && \
    apt-get install -y git

# Set your Git credentials and configure Git
RUN git config --global user.email "$GIT_EMAIL" \
    && git config --global user.name "$GIT_NAME" \
    && git config --global credential.helper store \
    && echo "https://$GIT_USERNAME:$GIT_TOKEN@github.com" > ~/.git-credentials \
    && git config --global credential.helper 'store --file ~/.git-credentials'

#setting docs
RUN git clone https://github.com/harsh-jman/harsh-jman.github.io dbt/target

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
CMD gunicorn --workers=2 --bind 0.0.0.0:$PORT server:app
