from git import Repo, GitCommandError

def commit_files_to_repo():
    repo_path = 'DBT/target'
    commit_message = 'auto docs generated'
    # Read environment variables
    
    if not repo_path or not commit_message:
        print("Error: Environment variables not set.")
        return

    try:
        # Initialize the Git repository object
        repo = Repo(repo_path)
        
        # Add all files to the index
        repo.git.add(all=True)
        
        # Commit the changes
        repo.index.commit(commit_message)
        
        # Push the changes to the remote repository
        origin = repo.remote(name='origin')
        origin.push()
        print("Changes pushed successfully.")
    except GitCommandError as e:
        print("An error occurred:", e)
