import sqlite3
import json

conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()

cursor.execute("SELECT id, surah_id, ayah_number, word_position, arabic_text, translation_fa FROM words WHERE surah_id = 1 AND ayah_number = 1")
rows = cursor.fetchall()

result = []
for row in rows:
    result.append({
        'id': row[0],
        'surah_id': row[1],
        'ayah_number': row[2],
        'word_position': row[3],
        'arabic_text': row[4],
        'translation_fa': row[5]
    })

with open('scripts/db_output.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, ensure_ascii=False, indent=2)
