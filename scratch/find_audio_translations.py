import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def check_url(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=5, context=ctx) as resp:
            return resp.status == 200, resp.headers.get('Content-Type')
    except Exception as e:
        return False, str(e)

print("=== Searching AlQuran Cloud Audio Editions ===")
try:
    url = "https://api.alquran.cloud/v1/edition?format=audio"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=10, context=ctx) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        editions = data.get('data', [])
        print(f"Total audio editions found: {len(editions)}")
        for ed in editions:
            lang = ed.get('language')
            identifier = ed.get('identifier')
            name = ed.get('name')
            englishName = ed.get('englishName')
            type_ = ed.get('type')
            if lang in ['fa', 'en'] or 'persian' in name.lower() or 'english' in name.lower() or 'fa' in identifier.lower() or 'en' in identifier.lower():
                print(f"[{lang}] {identifier} -> {name} ({englishName}) - Type: {type_}")
                # Test Ayah 1:1 audio URL sample
                sample_url = f"https://cdn.islamic.network/quran/audio/128/{identifier}/1.mp3"
                ok, ct = check_url(sample_url)
                print(f"   Sample Audio (1:1): {sample_url} -> Status: {ok}")
except Exception as e:
    print(f"AlQuran Cloud error: {e}")

print("\n=== Searching EveryAyah Audio Translations ===")
everyayah_translations = [
    # Persian
    ("fa.hedayatfar", "Fooladvand - Hedayatfar (Persian)", "https://everyayah.com/data/fa.hedayatfar_hedayatfar_64kbps/001001.mp3"),
    ("fa.makarem", "Makarem Kabiri (Persian)", "https://everyayah.com/data/fa.makarem_kabiri_64kbps/001001.mp3"),
    ("fa.fooladvand", "Fooladvand (Persian)", "https://everyayah.com/data/fa.fooladvand_hedayatfar_40kbps/001001.mp3"),
    
    # English
    ("en.walk", "Ibrahim Walk (Sahih International - English)", "https://everyayah.com/data/Ibrahim_Walk_192kbps_2008/001001.mp3"),
    ("en.walk_32", "Ibrahim Walk (English 32kbps)", "https://everyayah.com/data/Ibrahim_Walk_32kbps/001001.mp3"),
    ("en.shakir", "Shakir (English)", "https://everyayah.com/data/en.shakir/001001.mp3"),
]

for identifier, name, sample_url in everyayah_translations:
    ok, ct = check_url(sample_url)
    print(f"[EveryAyah] {name} ({identifier}): {sample_url} -> Status: {ok}")

print("\n=== Searching Quran.com API v4 Recitations & Translations ===")
try:
    url = "https://api.quran.com/api/v4/resources/recitations"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=10, context=ctx) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        recs = data.get('recitations', [])
        for r in recs:
            r_name = r.get('reciter_name', '')
            r_style = r.get('style', '')
            r_id = r.get('id')
            r_lang = r.get('language_name', '')
            if 'persian' in r_name.lower() or 'english' in r_name.lower() or 'translation' in str(r_style).lower() or 'walk' in r_name.lower() or 'hedayatfar' in r_name.lower() or 'kabiri' in r_name.lower():
                print(f"ID: {r_id} | Name: {r_name} | Style: {r_style} | Lang: {r_lang}")
except Exception as e:
    print(f"Quran.com API error: {e}")
