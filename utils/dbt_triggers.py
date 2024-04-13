from dbt.cli.main import dbtRunner, dbtRunnerResult
import os

def dbtRun():
    try:
        # Store the current working directory
        original_path = os.getcwd()

        # Navigate to the directory containing your dbt project
        os.chdir("DBT/")

        # Initialize dbtRunner
        dbt = dbtRunner()

        # Create CLI args as a list of strings
        cli_args = ["run"]

        # Run the command
        res: dbtRunnerResult = dbt.invoke(cli_args)

        # Inspect the results
        for r in res.result:
            print(f"{r.node.name}: {r.status}")

    except Exception as e:
        print(f"Error: {str(e)}")
    
    finally:
        # Return to the original working directory
        os.chdir(original_path)


def dbtDocsGenerate():
    try:
        # Store the current working directory
        original_path = os.getcwd()

        # Navigate to the directory containing your dbt project
        os.chdir("DBT/")

        # Initialize dbtRunner
        dbt = dbtRunner()

        # Create CLI args as a list of strings
        cli_args = ["docs", "generate"]

        # Run the command
        res: dbtRunnerResult = dbt.invoke(cli_args)

    except Exception as e:
        print(f"Error: {str(e)}")

    finally:
        # Return to the original working directory
        os.chdir(original_path)

