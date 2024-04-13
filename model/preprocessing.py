import spacy
from spacy.lang.en.stop_words import STOP_WORDS

# Load English tokenizer from spaCy
nlp = spacy.load("en_core_web_md")
tokenizer = nlp.tokenizer

# Function to normalize text
def normalize_text(text):
    text = text.lower()
    text = text.encode("ascii", "ignore").decode()
    return text

# Function to remove stopwords
def remove_stopwords(text):
    return ' '.join(token.text for token in tokenizer(text) if token.text not in STOP_WORDS and len(token.text) > 1)

# Function to perform data cleaning on text data
def clean_text(text):
    if len(text.split()) == 1 or text == ' ':
        return text
    text = normalize_text(text)
    text = remove_stopwords(text)
    return text
