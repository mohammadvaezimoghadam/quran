import sqlite3
import urllib.request
import json
import time

DB_PATH = 'assets/database/quran.db'
LANGUAGES = ['en', 'ur', 'tr']

def add_columns():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    for lang in LANGUAGES:
        col_name = f'translation_{lang}'
        try:
            cursor.execute(f"ALTER TABLE words ADD COLUMN {col_name} TEXT")
        except sqlite3.OperationalError:
            print(f"Column {col_name} already exists.")
    conn.commit()
    conn.close()

def fetch_and_update():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    for surah_id in range(1, 115):
        print(f"Fetching data for Surah {surah_id}...")
        for lang in LANGUAGES:
            url = f"https://api.quran.com/api/v4/verses/by_chapter/{surah_id}?words=true&word_fields=translation&language={lang}"
            try:
                req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req) as response:
                    data = json.loads(response.read().decode())
                    
                    for verse in data['verses']:
                        ayah_number = verse['verse_number']
                        for word in verse['words']:
                            if word['char_type_name'] == 'word':
                                position = word['position']
                                translation = word['translation']['text']
                                
                                # Update database
                                col_name = f'translation_{lang}'
                                cursor.execute(f'''
                                    UPDATE words 
                                    SET {col_name} = ? 
                                    WHERE surah_id = ? AND ayah_number = ? AND word_position = ?
                                ''', (translation, surah_id, ayah_number, position))
            except Exception as e:
                print(f"Error fetching Surah {surah_id} for lang {lang}: {e}")
            
            # Sleep slightly to avoid hitting API rate limits too hard
            time.sleep(0.2)
        
        # Commit after each surah to save progress
        conn.commit()
        print(f"Surah {surah_id} completed.")
        
    conn.close()
    print("Database update completed.")

if __name__ == '__main__':
    add_columns()
    fetch_and_update()
