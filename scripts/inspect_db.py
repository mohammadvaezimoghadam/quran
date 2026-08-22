import sqlite3
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()

print("=== TRANSLATION_EDITIONS TABLE ===")
cursor.execute("PRAGMA table_info(translation_editions)")
cols = [c[1] for c in cursor.fetchall()]
print("Columns:", cols)

cursor.execute("SELECT * FROM translation_editions")
for row in cursor.fetchall():
    print(row)

conn.close()
