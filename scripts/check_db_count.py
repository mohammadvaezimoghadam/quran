import sqlite3
import json
conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM words WHERE translation_en IS NOT NULL")
count = cursor.fetchone()[0]
print(f"Words with english translation: {count}")
