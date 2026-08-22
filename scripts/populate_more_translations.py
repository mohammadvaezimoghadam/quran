import sqlite3
import json
import urllib.request
import sys
import time

sys.stdout.reconfigure(encoding='utf-8')

ADDITIONAL_TRANSLATIONS = [
    ('de.bubenheim', 'آلمانی بوبنهایم (Bubenheim & Elyas)', 'de', 'A. S. F. Bubenheim And N. Elyas', 'alquran_cloud', 'de.bubenheim'),
    ('ur.jalandhry', 'اردو جالندھری', 'ur', 'Fateh Muhammad Jalandhry', 'alquran_cloud', 'ur.jalandhry'),
    ('en.yusufali', 'انگلیسی یوسف علی', 'en', 'Abdullah Yusuf Ali', 'alquran_cloud', 'en.yusufali'),
    ('en.pickthall', 'انگلیسی پیکتال', 'en', 'Mohammed Marmaduke Pickthall', 'alquran_cloud', 'en.pickthall'),
    ('tr.diyanet', 'ترکی سازمان دیانت', 'tr', 'Diyanet Isleri', 'alquran_cloud', 'tr.diyanet'),
    ('az.mammadaliyev', 'آذربایجانی ممدعلی‌اف', 'az', 'Vasim Mammadaliyev and Ziya Bunyadov', 'alquran_cloud', 'az.mammadaliyev'),
    ('ku.asan', 'کردی آسان (برهان امین)', 'ku', 'Burhan Muhammad Amin', 'alquran_cloud', 'ku.asan'),
    ('ps.abdulwali', 'پشتو عبدالوالی خان', 'ps', 'Abdulwali Khan', 'alquran_cloud', 'ps.abdulwali'),
    ('ar.muyassar', 'عربی التفسیر المیسر', 'ar', 'King Fahd Quran Complex', 'alquran_cloud', 'ar.muyassar'),
    ('fa.hedayatfar', 'فارسی فولادوند (خوانش هدایت‌فر)', 'fa', 'هدایت‌فر (فولادوند)', 'alquran_cloud', 'fa.hedayatfarfooladvand'),
    ('sq.ahmeti', 'آلبانیایی احمدی', 'sq', 'Sherif Ahmeti', 'alquran_cloud', 'sq.ahmeti'),
    ('nl.siregar', 'هلندی سیرگار', 'nl', 'Sofian S. Siregar', 'alquran_cloud', 'nl.siregar'),
]

def sanitize_text(text):
    if not text:
        return ""
    return text.replace('\ufffd', '').replace('\x00', '').strip()

def fetch_alquran_cloud(source_id):
    url = f"https://api.alquran.cloud/v1/quran/{source_id}"
    print(f"   Downloading from AlQuran Cloud ({source_id})...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        ayahs = []
        for surah in data['data']['surahs']:
            for ayah in surah['ayahs']:
                ayahs.append(sanitize_text(ayah['text']))
        return ayahs

def main():
    conn = sqlite3.connect('assets/database/quran.db')
    cursor = conn.cursor()

    print("=== POPULATING ADDITIONAL TRANSLATIONS TO REACH 34 EDITIONS ===")

    success_count = 0

    for identifier, name, language, author, source_type, source_id in ADDITIONAL_TRANSLATIONS:
        print(f"\nProcessing [{identifier}] - {name}...")

        cursor.execute("SELECT COUNT(*) FROM translation_editions WHERE identifier=?", (identifier,))
        if cursor.fetchone()[0] > 0:
            print(f"   Already exists, skipping.")
            continue

        try:
            ayah_texts = fetch_alquran_cloud(source_id)

            if len(ayah_texts) != 6236:
                print(f"   WARNING: Fetched {len(ayah_texts)} ayahs (expected 6236). Skipping.")
                continue

            cursor.execute(
                "INSERT INTO translation_editions (identifier, name, language, author, is_downloaded) VALUES (?, ?, ?, ?, 1)",
                (identifier, name, language, author)
            )

            insert_rows = [(identifier, idx + 1, text) for idx, text in enumerate(ayah_texts)]
            cursor.executemany(
                "INSERT INTO translations (translation_id, ayah_id, text) VALUES (?, ?, ?)",
                insert_rows
            )

            conn.commit()
            print(f"   Successfully inserted {len(ayah_texts)} ayahs into database!")
            success_count += 1
            time.sleep(0.5)

        except Exception as e:
            print(f"   ERROR downloading/inserting [{identifier}]: {e}")
            conn.rollback()

    print(f"\nCompleted: Added {success_count} new editions!")
    conn.close()

if __name__ == '__main__':
    main()
