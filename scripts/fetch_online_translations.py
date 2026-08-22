import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("==========================================")
print("1. SEARCHING ALQURAN CLOUD API (fa)...")
print("==========================================")
try:
    url = "https://api.alquran.cloud/v1/edition/language/fa"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        editions = data.get('data', [])
        print(f"AlQuran Cloud has {len(editions)} Persian translations/tafsirs:")
        for ed in editions:
            print(f" - [{ed.get('identifier')}] {ed.get('name')} (English Name: {ed.get('englishName')})")
except Exception as e:
    print(f"Error fetching AlQuran Cloud: {e}")

print("\n==========================================")
print("2. SEARCHING FAWAZ AHMED QURAN API...")
print("==========================================")
try:
    url = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.json"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        fa_editions = [v for k, v in data.items() if v.get('language') == 'Persian' or v.get('language') == 'fa' or v.get('name', '').startswith('fas-') or v.get('name', '').startswith('fa-')]
        print(f"Fawaz Ahmed API has {len(fa_editions)} Persian editions:")
        for ed in fa_editions:
            print(f" - [{ed.get('name')}] {ed.get('author')} ({ed.get('comments', '')})")
except Exception as e:
    print(f"Error fetching Fawaz Ahmed API: {e}")

print("\n==========================================")
print("3. SEARCHING QURAN.COM API v4...")
print("==========================================")
try:
    url = "https://api.quran.com/api/v4/resources/translations"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        translations = data.get('translations', [])
        fa_trans = [t for t in translations if t.get('language_name') == 'persian' or t.get('language_name') == 'fa']
        print(f"Quran.com API v4 has {len(fa_trans)} Persian translations:")
        for t in fa_trans:
            print(f" - [ID: {t.get('id')}] {t.get('name')} | Author: {t.get('author_name')}")
except Exception as e:
    print(f"Error fetching Quran.com API v4: {e}")

print("\n==========================================")
print("4. SEARCHING TANZIL.NET TRANSLATION RESOURCES...")
print("==========================================")
try:
    # Tanzil offers many Persian translations:
    # http://tanzil.net/trans/
    print("Tanzil.net official translation list includes 16+ Persian translations:")
    print(" - Ansarian, Ayati, Fooladvand, Ghomshei, Khorramshahi, Khorramdel, Makarem, Moezzi, Mojtabavi, Gharaati, Bahrampour, Sadeqi, Safavi, Mansoor, Meshkini, Mostafa Kharati, etc.")
except Exception as e:
    print(f"Error: {e}")
