import sqlite3
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("==================================================")
print("=== DATABASE INTEGRITY & COMPLETENESS TEST ===")
print("==================================================")

conn = sqlite3.connect('assets/database/quran.db')
cursor = conn.cursor()

# 1. Total Editions Count
cursor.execute("SELECT COUNT(*) FROM translation_editions")
total_editions = cursor.fetchone()[0]
print(f"1. Total Translation Editions: {total_editions} (Target: 34)")

# 2. Total Translations Ayahs Count
cursor.execute("SELECT COUNT(*) FROM translations")
total_ayahs = cursor.fetchone()[0]
expected_total = total_editions * 6236
print(f"2. Total Ayah Rows in 'translations': {total_ayahs} (Expected: {expected_total})")

# 3. Verify Every Single Edition
cursor.execute("SELECT identifier, name, language, author FROM translation_editions ORDER BY language, name")
editions = cursor.fetchall()

all_passed = True

print("\n=== VERIFYING ALL 34 EDITIONS ===")
for idx, (ident, name, lang, author) in enumerate(editions):
    cursor.execute("SELECT COUNT(*), MIN(ayah_id), MAX(ayah_id) FROM translations WHERE translation_id=?", (ident,))
    count, min_id, max_id = cursor.fetchone()
    
    # Check for empty or corrupt texts
    cursor.execute("SELECT COUNT(*) FROM translations WHERE translation_id=? AND (text IS NULL OR text = '')", (ident,))
    empty_count = cursor.fetchone()[0]

    # Check for replacement character U+FFFD
    cursor.execute("SELECT COUNT(*) FROM translations WHERE translation_id=? AND text LIKE '%\ufffd%'", (ident,))
    artifact_count = cursor.fetchone()[0]

    is_valid = (count == 6236 and min_id == 1 and max_id == 6236 and empty_count == 0 and artifact_count == 0)
    status_str = "PASSED ✓" if is_valid else "FAILED ✗"
    if not is_valid:
        all_passed = False

    print(f"{idx+1:2d}. [{ident}] '{name}' ({lang.upper()}) -> {count} ayahs | Range: {min_id}-{max_id} | Empty: {empty_count} | Artifacts: {artifact_count} | Status: {status_str}")

# 4. Sample Query Test (Ayat Al-Kursi, Surah 2:255 = Ayah ID 262)
print("\n=== SAMPLE QUERY TEST: Surah 2:255 (Ayat Al-Kursi - Ayah ID 262) ===")
cursor.execute("""
    SELECT e.name, t.text 
    FROM translations t 
    JOIN translation_editions e ON t.translation_id = e.identifier 
    WHERE t.ayah_id = 262 
    LIMIT 5
""")
sample_rows = cursor.fetchall()
for ed_name, text in sample_rows:
    print(f" • [{ed_name}]: {text[:80]}...")

print("\n==================================================")
if all_passed and total_editions == 34 and total_ayahs == expected_total:
    print("ALL TESTS PASSED SUCCESSFULLY! 🎯 100% PERFECT DATA INTEGRITY.")
else:
    print("SOME TESTS FAILED! PLEASE REVIEW ISSUES ABOVE.")
print("==================================================")

conn.close()
