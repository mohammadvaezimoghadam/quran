import sqlite3
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()

print("=== 1. TRANSLATION_EDITIONS SCHEMA & SAMPLE ROWS ===")
cursor.execute("PRAGMA table_info(translation_editions)")
print("Columns:", cursor.fetchall())
cursor.execute("SELECT * FROM translation_editions")
for row in cursor.fetchall():
    print("Edition Row:", row)

print("\n=== 2. TRANSLATIONS SCHEMA & SAMPLE ROWS ===")
cursor.execute("PRAGMA table_info(translations)")
print("Columns:", cursor.fetchall())
cursor.execute("SELECT * FROM translations WHERE translation_id='fa.ansarian' LIMIT 5")
for row in cursor.fetchall():
    print("Translation Row:", row)

print("\n=== 3. AYAH_ID RANGE CHECK ===")
cursor.execute("SELECT MIN(id), MAX(id), COUNT(*) FROM ayahs")
print("Ayahs Table (id min, max, count):", cursor.fetchone())

cursor.execute("SELECT MIN(ayah_id), MAX(ayah_id), COUNT(*) FROM translations WHERE translation_id='fa.ansarian'")
print("Ansarian Translation (ayah_id min, max, count):", cursor.fetchone())

print("\n=== 4. CHECK ALL EXISTING TRANSLATION COUNTS ===")
cursor.execute("SELECT translation_id, COUNT(*) FROM translations GROUP BY translation_id")
for row in cursor.fetchall():
    print(f"Translation '{row[0]}': {row[1]} ayahs")

conn.close()
