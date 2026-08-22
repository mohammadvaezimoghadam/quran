import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("==================================================")
print("=== SEARCHING FOR PERSIAN TAFSIR ENDPOINTS ===")
print("==================================================")

# 1. Fawaz Ahmed Editions List (checks if any Persian tafsirs exist)
url_fawaz_editions = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.json"
print(f"1. Searching Fawaz Ahmed Quran API: {url_fawaz_editions}")
try:
    req = urllib.request.Request(url_fawaz_editions, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        editions = json.loads(resp.read().decode('utf-8'))
        fa_tafsirs = []
        for key, info in editions.items():
            name = str(info.get('name', '')).lower()
            lang = str(info.get('language', '')).lower()
            text_type = str(info.get('type', '')).lower()
            if lang in ['persian', 'fa'] or 'tafsir' in key.lower() or 'almizan' in key.lower():
                fa_tafsirs.append((key, info))
        
        print(f"Found {len(fa_tafsirs)} matching Persian/Tafsir editions in Fawaz API:")
        for k, info in fa_tafsirs[:15]:
            print(f" - [{k}] {info.get('name')} | Lang: {info.get('language')} | Author: {info.get('author')}")
except Exception as e:
    print(f"Error checking Fawaz API: {e}")

# 2. Quran.com API v4 Persian Tafsirs
url_qurancom_resources = "https://api.quran.com/api/v4/resources/tafsirs?language=fa"
print(f"\n2. Searching Quran.com API v4 (Language: Persian/fa): {url_qurancom_resources}")
try:
    req = urllib.request.Request(url_qurancom_resources, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        tafsirs = data.get('tafsirs', [])
        print(f"Found {len(tafsirs)} Persian Tafsirs in Quran.com API:")
        for tf in tafsirs:
            print(f" - [ID: {tf.get('id')}] {tf.get('name')} - Author: {tf.get('author_name')}")
except Exception as e:
    print(f"Error checking Quran.com API: {e}")

# 3. AlQuran Cloud Persian Tafsirs
url_alquran_fa = "https://api.alquran.cloud/v1/edition/language/fa"
print(f"\n3. Searching AlQuran Cloud (Language: fa): {url_alquran_fa}")
try:
    req = urllib.request.Request(url_alquran_fa, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        editions = data.get('data', [])
        tafsir_eds = [e for e in editions if e.get('format') == 'text' and e.get('type') == 'tafsir']
        print(f"Found {len(tafsir_eds)} Persian Tafsirs in AlQuran Cloud:")
        for ed in tafsir_eds:
            print(f" - [{ed.get('identifier')}] {ed.get('name')}")
except Exception as e:
    print(f"Error checking AlQuran Cloud: {e}")

print("\n==================================================")
