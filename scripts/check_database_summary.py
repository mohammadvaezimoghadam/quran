import sqlite3
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()

print("=== ALL EDITIONS CURRENTLY IN QURAN.DB ===")
cursor.execute("SELECT identifier, name, language, author FROM translation_editions")
rows = cursor.fetchall()
for idx, row in enumerate(rows):
    cursor.execute("SELECT COUNT(*) FROM translations WHERE translation_id=?", (row[0],))
    count = cursor.fetchone()[0]
    print(f"{idx + 1:2d}. [{row[0]}] -> '{row[1]}' | Lang: {row[2]} | Author: {row[3]} | Ayahs Count: {count}")

print(f"\nTotal Editions in Database: {len(rows)}")
conn.close()
