import os
import re
import urllib.request
import sqlite3

# Configuration
URL = "https://raw.githubusercontent.com/menelik3/cmudict-ipa/master/cmudict-0.7b-ipa.txt"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "database")
DB_NAME = "ipa_dictionary.db"
DB_PATH = os.path.join(OUTPUT_DIR, DB_NAME)

def main():
    print("--- IPA Dictionary Builder ---")
    
    # Ensure assets/database directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Database target path: {DB_PATH}")
    
    # 1. Download the dictionary
    print(f"Downloading CMUdict-IPA from: {URL}...")
    try:
        response = urllib.request.urlopen(URL)
        raw_data = response.read().decode('utf-8')
        print("Download successful!")
    except Exception as e:
        print(f"Error downloading the dictionary: {e}")
        return

    # 2. Setup SQLite Database
    if os.path.exists(DB_PATH):
        print("Removing existing database file...")
        os.remove(DB_PATH)
        
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create Table
    cursor.execute("""
    CREATE TABLE ipa_words (
        word TEXT PRIMARY KEY,
        ipa TEXT NOT NULL
    )
    """)
    print("Database table 'ipa_words' created.")

    # 3. Parse and Insert Data
    print("Parsing dictionary entries and preparing batch insert...")
    lines = raw_data.splitlines()
    entries = []
    
    # Pattern to match numbers in parentheses, e.g., hello(1) -> hello
    paren_pattern = re.compile(r'\(\d+\)')
    
    # Track duplicates to merge pronunciations if needed
    word_dict = {}

    for line in lines:
        if not line or line.startswith(';'):
            continue
            
        parts = line.split('\t')
        if len(parts) < 2:
            continue
            
        raw_word = parts[0].strip()
        ipa_transcription = parts[1].strip()
        
        # Clean word (lowercase, remove parens from duplicates)
        clean_word = paren_pattern.sub('', raw_word).strip().lower()
        
        if not clean_word:
            continue

        # If word already exists, we combine pronunciations, separating them by a comma
        if clean_word in word_dict:
            existing_ipa = word_dict[clean_word]
            # Split and combine unique pronunciations
            existing_list = [p.strip() for p in existing_ipa.split(',')]
            new_list = [p.strip() for p in ipa_transcription.split(',')]
            
            combined_list = existing_list
            for p in new_list:
                if p not in combined_list:
                    combined_list.append(p)
                    
            word_dict[clean_word] = ", ".join(combined_list)
        else:
            word_dict[clean_word] = ipa_transcription

    # Prepare list for executemany
    for word, ipa in word_dict.items():
        entries.append((word, ipa))

    print(f"Total unique words parsed: {len(entries)}")
    
    # Execute batch insertion in a transaction
    try:
        cursor.executemany("INSERT INTO ipa_words (word, ipa) VALUES (?, ?)", entries)
        conn.commit()
        print(f"Successfully inserted {len(entries)} words into the database.")
    except Exception as e:
        conn.rollback()
        print(f"Error executing batch insert: {e}")
    finally:
        conn.close()
        
    print("--- Generation Complete ---")

if __name__ == "__main__":
    main()
