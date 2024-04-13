import pandas as pd
from .indexing import build_embedding_index_from_df
from sklearn.preprocessing import LabelEncoder


def training(data_path, text_column, save_path):
    # Read the data from CSV
    df = pd.read_csv(data_path)


    label_encoder = LabelEncoder()
    
    df['proficiency'] = label_encoder.fit_transform(df['proficiency'])

    columns_to_concat = ['comments','skillName','certificateName','CertificateDescription','issuingAuthority','projectName','ProjectDescription']

    df['text'] = df['text'] = df.apply(lambda row: ' '.join([str(row[col]) for col in columns_to_concat]), axis=1)

    # Call the build_faiss_index function
    build_embedding_index_from_df(df, text_column, save_path)

    return "FAISS index training completed successfully and saved at: {}".format(save_path)
