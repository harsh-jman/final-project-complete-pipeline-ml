import numpy as np
from scipy import spatial
from .preprocessing import clean_text, nlp

# Function to generate token
def generate_token(text):
    cleaned_text = clean_text(text)
    doc = nlp(cleaned_text)
    embedding = np.mean([token.vector for token in doc], axis=0)
    return embedding

def normalize_weights(weights):
    """
    Normalize the list of weights using the normal equation to scale between 0 and 1.

    Args:
    - weights: List of numeric values

    Returns:
    - normalized_weights: List of normalized numeric values
    """
    min_val = min(weights)
    max_val = max(weights)
    normalized_weights = [(x - min_val) / (max_val - min_val) for x in weights]
    return normalized_weights


def build_embedding_index_from_df(df, text_column, save_path):
    """
    Build an index for embeddings generated from a DataFrame containing text data.

    Args:
    - df: DataFrame containing the data
    - text_column: Name of the column containing text data
    - save_path: Path to save the embeddings
    
    Returns:
    - indices: List containing the corresponding indices of the embeddings
    """
    
    # Initialize an empty list to store embeddings
    all_embeddings = []
    
    # Initialize an empty list to store indices
    indices = []

    # Iterate over each row in the DataFrame
    for index, row in df.iterrows():
        # Get text from the specified column
        text = str(row[text_column])
        
        # Generate embedding for the text using your tokenization and vectorization function
        embedding = generate_token(text)

        # Get additional numeric values from columns
        proficiency = row['proficiency']
        hackerRankScore = row['hackerRankScore']
        rating = row['rating']
        
        # Normalize the additional weights
        weights = [proficiency, hackerRankScore, rating]
        weights_normalized = normalize_weights(weights)

        # Concatenate the normalized weights to the embedding
        embedding = np.concatenate((embedding, weights_normalized))
        
        # Append the embedding to the list
        all_embeddings.append(embedding)
        
        # Append the index to the indices list
        indices.append(index)

    # Convert the list of embeddings to a NumPy array
    all_embeddings = np.array(all_embeddings)

    # Save the NumPy array and indices to a file
    np.savez(save_path, embeddings=all_embeddings, indices=indices)

    # Return the indices
    return indices



def similarity_search(text,temperature,embeddings, indices, top_n=5):
    """
    Perform similarity search based on cosine similarity.

    Args:
    - query_embedding: Embedding of the query text
    - embeddings: NumPy array containing the embeddings of stored texts
    - indices: List containing the corresponding indices of the stored embeddings
    - top_n: Number of top results to return
    
    Returns:
    - top_results: List of tuples containing (index, similarity_score) of the top similar texts
    """

    query_embedding = generate_token(text)
    
    proficiency = map_values(temperature)['proficiency']
    hackerRankScore = map_values(temperature)['hackerRankScore']
    rating = map_values(temperature)['rating']
    
    weights = [proficiency, hackerRankScore, rating]
    weights_normalized = normalize_weights(weights)

    query_embedding = np.concatenate((query_embedding, weights_normalized))
    
    # Calculate cosine similarity between query_embedding and each stored embedding
    similarities = 1 - spatial.distance.cdist([query_embedding], embeddings, metric='cosine')[0]

    # Sort indices based on similarity scores (descending order)
    sorted_indices = sorted(range(len(indices)), key=lambda i: similarities[i], reverse=True)

    # Get the top N results along with their similarity scores
    top_results = [(indices[i], similarities[i]) for i in sorted_indices[:top_n]]

    return top_results



# Function to map temperature values to numerical features
def map_values(value):
    proficiency = round(value * 2)
    hacker_rank_score = round(value * 100)
    rating = round(value * 4) + 1

    return {
        'proficiency': proficiency,
        'hackerRankScore': hacker_rank_score,
        'rating': rating
    }
