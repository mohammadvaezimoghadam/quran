import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("==================================================")
print("=== TESTING TAFSIR EDITIONS LIST ENDPOINTS ===")
print("==================================================")

# 1. AlQuran Cloud Tafsir Editions List
url_alquran_editions = "https://api.alquran.cloud/v1/edition/type/tafsir"
print(f"\n1. AlQuran Cloud Tafsirs List: {url_alquran_editions}")
try:
    req = urllib.request.Request(url_alquran_editions, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        editions = data.get('data', [])
        print(f"Total Tafsir Editions found: {len(editions)}")
        for ed in editions[:10]:
            print(f" - [{ed.get('identifier')}] {ed.get('name')} ({ed.get('language')}) - {ed.get('englishName')}")
except Exception as e:
    print(f"Error: {e}")

# 2. Quran.com API v4 Tafsirs List
url_qurancom_editions = "https://api.quran.com/api/v4/resources/tafsirs"
print(f"\n2. Quran.com API v4 Tafsirs List: {url_qurancom_editions}")
try:
    req = urllib.request.Request(url_qurancom_editions, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        tafsirs = data.get('tafsirs', [])
        print(f"Total Tafsirs found: {len(tafsirs)}")
        for tf in tafsirs[:10]:
            print(f" - [ID: {tf.get('id')}] {tf.get('name')} ({tf.get('language_name')}) - Author: {tf.get('author_name')}")
except Exception as e:
    print(f"Error: {e}")

print("\n==================================================")
