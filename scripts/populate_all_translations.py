import sqlite3
import json
import urllib.request
import sys
import time

sys.stdout.reconfigure(encoding='utf-8')

# Target translations list matching Hablolmatin & Tanzil / AlQuran Cloud
# Format: (identifier, display_name, language, author, source_type, source_id)
TARGET_TRANSLATIONS = [
    # 1. Persian (فارسی)
    ('fa.bahrampour', 'استاد ابوالفضل بهرام‌پور', 'fa', 'ابوالفضل بهرام‌پور', 'alquran_cloud', 'fa.bahrampour'),
    ('fa.sadeqi', 'دکتر محمد صادقی تهرانی', 'fa', 'محمد صادقی تهرانی', 'alquran_cloud', 'fa.sadeqi'),
    ('fa.safavi', 'ترجمه بر اساس المیزان (صفوی)', 'fa', 'محمدرضا صفوی', 'alquran_cloud', 'fa.safavi'),
    ('fa.payandeh', 'ابوالقاسم پاینده', 'fa', 'ابوالقاسم پاینده', 'fawaz', 'fas-abolqasampayand'),
    ('fa.pourjavadi', 'رضا پورجوادی', 'fa', 'رضا پورجوادی', 'fawaz', 'fas-rezapourjavadi'),
    ('fa.halabi', 'استاد علی‌اصغر حلبی', 'fa', 'علی‌اصغر حلبی', 'fawaz', 'fas-aliasgharhalabi'),
    ('fa.khwajavi', 'استاد محمد خواجوی', 'fa', 'محمد خواجوی', 'fawaz', 'fas-mohammadkhwajav'),
    ('fa.rezai', 'دکتر محمدعلی رضایی اصفهانی', 'fa', 'محمدعلی رضایی اصفهانی', 'fawaz', 'fas-mohammadalireza'),
    ('fa.rahnama', 'استاد علی رهنما', 'fa', 'علی رهنما', 'fawaz', 'fas-alirahnama'),
    ('fa.siraj', 'احمد سراج (ترجمه سراج)', 'fa', 'احمد سراج', 'fawaz', 'fas-ahmadsiraj'),
    ('fa.kavianpour', 'دکتر احمد کاویان‌پور', 'fa', 'احمد کاویان‌پور', 'fawaz', 'fas-ahmadkavianpour'),
    ('fa.barzi', 'دکتر مسعود برزی', 'fa', 'مسعود برزی', 'fawaz', 'fas-masoudbarzi'),
    ('fa.taheri', 'استاد طاهری', 'fa', 'طاهری', 'fawaz', 'fas-taheri'),
    ('fa.maleki', 'استاد علی ملکی (ترجمه خوانا)', 'fa', 'علی ملکی', 'fawaz', 'fas-alimaleki'),
    ('fa.tabanashr', 'مرکز طبع و نشر قرآن کریم', 'fa', 'مرکز طبع و نشر', 'fawaz', 'fas-markaztabwanash'),
    ('fa.abulmaali', 'ابوالمعالی (منظوم/شعر)', 'fa', 'ابوالمعالی', 'fawaz', 'fas-abulmaali'),
    ('fa.tashakori', 'تشکری (منظوم/شعر)', 'fa', 'تشکری', 'fawaz', 'fas-tashakori'),
    ('fa.tajikaldari', 'دکتر حسین تاجی کالداری', 'fa', 'حسین تاجی کالداری', 'fawaz', 'fas-drhussientagi'),
    ('fa.islamhouse', 'گروه مترجمان اسلام‌هاوس', 'fa', 'IslamHouse Team', 'fawaz', 'fas-islamhousecompe'),
    
    # 2. International (بین‌المللی / خارجی)
    ('en.sahih', 'انگلیسی صحیح اینترنشنال', 'en', 'Saheeh International', 'alquran_cloud', 'en.sahih'),
    ('en.shakir', 'انگلیسی شاکر', 'en', 'Mohammad Habib Shakir', 'alquran_cloud', 'en.shakir'),
    ('en.irving', 'انگلیسی ایروینگ', 'en', 'T.B. Irving', 'fawaz', 'eng-tbirving'),
    ('de.amadiya', 'آلمانی احمدیا', 'en', 'Ahmadiyya Group', 'fawaz', 'deu-abubakrmachmudr'),
    ('es.cortes', 'اسپانیایی کورتز', 'es', 'Julio Cortes', 'alquran_cloud', 'es.cortes'),
    ('it.piccardo', 'ایتالیایی پیکاردو', 'it', 'Hamza Roberto Piccardo', 'alquran_cloud', 'it.piccardo'),
    ('ru.kuliev', 'روسی کولینف', 'ru', 'Elmir Kuliev', 'alquran_cloud', 'ru.kuliev'),
    ('fr.hamidullah', 'فرانسه حمید‌الله', 'fr', 'Muhammad Hamidullah', 'alquran_cloud', 'fr.hamidullah'),
]

def sanitize_text(text):
    if not text:
        return ""
    # Remove U+FFFD (Replacement character) and null bytes
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

def fetch_fawaz(source_id):
    url = f"https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/{source_id}.json"
    print(f"   Downloading from Fawaz Ahmed API ({source_id})...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        quran_list = data.get('quran', [])
        ayahs = [sanitize_text(item['text']) for item in quran_list]
        return ayahs

def main():
    conn = sqlite3.connect('assets/database/quran.db')
    cursor = conn.cursor()

    print("=== STARTING POPULATION OF NEW TRANSLATIONS ===")

    success_count = 0
    fail_count = 0

    for identifier, name, language, author, source_type, source_id in TARGET_TRANSLATIONS:
        print(f"\nProcessing [{identifier}] - {name}...")

        # Check if already exists in translation_editions
        cursor.execute("SELECT COUNT(*) FROM translation_editions WHERE identifier=?", (identifier,))
        if cursor.fetchone()[0] > 0:
            print(f"   Already exists in database, skipping download.")
            continue

        try:
            if source_type == 'alquran_cloud':
                ayah_texts = fetch_alquran_cloud(source_id)
            elif source_type == 'fawaz':
                ayah_texts = fetch_fawaz(source_id)
            else:
                print(f"   Unknown source type {source_type}")
                continue

            if len(ayah_texts) != 6236:
                print(f"   WARNING: Fetched {len(ayah_texts)} ayahs (expected 6236). Skipping.")
                fail_count += 1
                continue

            # Insert into translation_editions
            cursor.execute(
                "INSERT INTO translation_editions (identifier, name, language, author, is_downloaded) VALUES (?, ?, ?, ?, 1)",
                (identifier, name, language, author)
            )

            # Insert all 6236 ayahs into translations table
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
            fail_count += 1
            conn.rollback()

    print(f"\n==========================================")
    print(f"POPULATION SUMMARY: {success_count} added, {fail_count} failed.")
    print(f"==========================================")

    conn.close()

if __name__ == '__main__':
    main()
