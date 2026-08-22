import sqlite3
import urllib.request
import json
import os
import sys
import time

def populate_words_table():
    db_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "database", "quran.db")
    
    if not os.path.exists(db_path):
        print(f"❌ Database not found at {db_path}!")
        sys.exit(1)
        
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Ensure words table exists and clear it
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS words (
        id INTEGER PRIMARY KEY,
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        word_position INTEGER NOT NULL,
        arabic_text TEXT NOT NULL,
        translation_fa TEXT NOT NULL
    );
    """)
    cursor.execute("DELETE FROM words;")
    
    print("Starting full Quran word-by-word fetching...")
    
    total_words = 0
    
    for surah_id in range(1, 115):
        print(f"Fetching words for Surah {surah_id}...")
        url = f"https://api.quran.com/api/v4/verses/by_chapter/{surah_id}?words=true&word_fields=text_uthmani&language=fa&per_page=300"
        
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        try:
            with urllib.request.urlopen(req) as response:
                if response.status != 200:
                    print(f"Failed to fetch Surah {surah_id}: HTTP {response.status}")
                    continue
                    
                data = json.loads(response.read().decode('utf-8'))
                verses = data.get("verses", [])
                
                for verse in verses:
                    ayah_number = verse.get("verse_number")
                    words = verse.get("words", [])
                    
                    for word in words:
                        # Exclude end of ayah markers from the word list if they appear
                        if word.get("char_type_name") != "word":
                            continue
                            
                        position = word.get("position")
                        arabic_text = word.get("text_uthmani", "")
                        translation_fa = word.get("translation", {}).get("text", "")
                        
                        cursor.execute("""
                        INSERT INTO words (surah_id, ayah_number, word_position, arabic_text, translation_fa)
                        VALUES (?, ?, ?, ?, ?)
                        """, (surah_id, ayah_number, position, arabic_text, translation_fa))
                        
                        total_words += 1
                        
                conn.commit() # commit after every surah
                time.sleep(0.5) # respect API rate limits
                
        except Exception as e:
            print(f"Error fetching Surah {surah_id}: {e}")
            continue

    # Add indices for fast lookup
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_words_lookup ON words(surah_id, ayah_number);")
    conn.commit()
    conn.close()
    
    print(f"SUCCESS! Added {total_words} words to the database.")

if __name__ == "__main__":
    populate_words_table()
