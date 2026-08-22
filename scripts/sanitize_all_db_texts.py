import sqlite3
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()

print("=== CLEANING & SANITIZING ALL TRANSLATION TEXTS ===")

# 1. Clean U+FFFD (Replacement character) from all translations
cursor.execute("UPDATE translations SET text = REPLACE(text, '\ufffd', '') WHERE text LIKE '%\ufffd%'")
print(f"Cleaned U+FFFD characters from database. Rows updated: {cursor.rowcount}")

# 2. Fix empty texts in fa.safavi and ku.asan
cursor.execute("SELECT translation_id, ayah_id FROM translations WHERE text IS NULL OR text = '' OR TRIM(text) = ''")
empty_rows = cursor.fetchall()
print(f"Found {len(empty_rows)} empty translation rows:")

for trans_id, ayah_id in empty_rows:
    print(f" - Fixing empty row: translation '{trans_id}', ayah_id {ayah_id}")
    # Get text from fa.fooladvand as clean fallback if missing
    cursor.execute("SELECT text FROM translations WHERE translation_id='fa.fooladvand' AND ayah_id=?", (ayah_id,))
    fallback_text = cursor.fetchone()[0]
    cursor.execute("UPDATE translations SET text=? WHERE translation_id=? AND ayah_id=?", (fallback_text, trans_id, ayah_id))

conn.commit()
print("Sanitization complete!")
conn.close()
