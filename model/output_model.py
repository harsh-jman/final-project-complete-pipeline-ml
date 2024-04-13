from .indexing import similarity_search
import pandas as pd
import numpy as np

def load_embedding_index(file_path):
    """
    Load embeddings and their corresponding indices from a file.

    Args:
    - file_path: Path to the file containing embeddings and indices
    
    Returns:
    - embeddings: NumPy array containing the embeddings
    - indices: List containing the corresponding indices of the embeddings
    """
    data = np.load(file_path)
    embeddings = data['embeddings']
    indices = data['indices']
    return embeddings, indices



def output(input_text,temperature,n):
    """
    Predict similar items to the input text using the FAISS index.

    Args:
    - input_text (str): The input text for which similar items are to be predicted.
    - faiss_index (faiss.Index): The FAISS index used to find similar items.

    Returns:
    - tuple: A tuple containing two lists, where the first list contains distances and the second list contains indices.
    """
    embeddings, indices = load_embedding_index("resources/embedding_index.npz")

    matched_indices = similarity_search(input_text,temperature,embeddings,indices,top_n=n)
    
    df=pd.read_csv("data/artifact/synthetic_data.csv")
    top_results_df = pd.DataFrame(matched_indices, columns=["Index", "Similarity"])
    matched_rows = df.iloc[[result[0] for result in matched_indices]]

    final_df = pd.merge(matched_rows, top_results_df, left_index=True, right_on="Index")

    # Reorder columns as required
    selected_df = final_df[['userId_x','fullname','Similarity']]

    return selected_df.T.to_dict()
