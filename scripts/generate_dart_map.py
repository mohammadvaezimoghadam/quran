import sqlite3
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()

cursor.execute("SELECT identifier, name FROM translation_editions ORDER BY language, name")
rows = cursor.fetchall()

print("const Map<String, String> translatorNameToIdMap = {")
for ident, name in rows:
    print(f"  '{name}': '{ident}',")
print("};")

print("\nstatic const List<String> _translators = [")
for ident, name in rows:
    print(f"  '{name}',")
print("];")

conn.close()
