import urllib.request
import json
import re
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def safe_str(s):
    if not s: return ""
    return str(s).encode('ascii', 'ignore').decode('ascii')

def get_json(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=8, context=ctx) as r:
            return json.loads(r.read().decode('utf-8'))
    except Exception as e:
        print(f"Error {url}: {safe_str(e)}")
        return None

def check_url(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=4, context=ctx) as r:
            return r.status == 200
    except:
        return False

print("=== 1. SEARCHING ALQURAN CLOUD API FOR AUDIO TRANSLATIONS ===")
data = get_json("https://api.alquran.cloud/v1/edition?format=audio")
if data and 'data' in data:
    for ed in data['data']:
        lang = ed.get('language')
        name = safe_str(ed.get('name', ''))
        eng_name = safe_str(ed.get('englishName', ''))
        ident = safe_str(ed.get('identifier'))
        type_ = safe_str(ed.get('type'))
        if lang in ['fa', 'en'] or type_ == 'translation':
            sample = f"https://cdn.islamic.network/quran/audio/128/{ident}/1.mp3"
            ok = check_url(sample)
            print(f"AlQuranCloud -> [{safe_str(lang).upper()}] {ident} | {eng_name} | Type: {type_} | Working: {ok}")

print("\n=== 2. SEARCHING QURAN.COM API V4 ===")
q_data = get_json("https://api.quran.com/api/v4/resources/recitations")
if q_data and 'recitations' in q_data:
    for r in q_data['recitations']:
        r_name = safe_str(r.get('reciter_name', ''))
        r_style = safe_str(r.get('style', ''))
        r_id = r.get('id')
        r_lang = safe_str(r.get('language_name', ''))
        print(f"QuranCom -> ID: {r_id} | Name: {r_name} | Style: {r_style} | Lang: {r_lang}")

print("\n=== 3. SEARCHING TANZIL AUDIO TRANSLATIONS ===")
tanzil_url = "https://tanzil.net/res/audio/reciters.js"
req = urllib.request.Request(tanzil_url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=8, context=ctx) as r:
        content = r.read().decode('utf-8')
        matches = re.findall(r'\{[^\}]*\}', content)
        for m in matches:
            sm = safe_str(m)
            if 'fa' in sm.lower() or 'en' in sm.lower() or 'translation' in sm.lower() or 'persian' in sm.lower() or 'english' in sm.lower():
                print(f"Tanzil -> {sm}")
except Exception as e:
    print(f"Tanzil error: {safe_str(e)}")

print("\n=== 4. SEARCHING IRANIAN AUDIO TRANSLATION SERVERS ===")
iranian_candidates = [
    ("Abolfazl Bahrampour", "http://dl.aviny.com/voice/quran/bahrampour/001.mp3", "http://dl.anhar.ir/quran/bahrampour/001.mp3"),
    ("Haddad Adel", "http://dl.aviny.com/voice/quran/haddad-adel/001.mp3", "http://dl.anhar.ir/quran/haddad-adel/001.mp3"),
    ("Khorramshahi", "http://dl.aviny.com/voice/quran/khorramshahi/001.mp3", "http://dl.anhar.ir/quran/khorramshahi/001.mp3"),
    ("Meshkini", "http://dl.aviny.com/voice/quran/meshkini/001.mp3", "http://dl.anhar.ir/quran/meshkini/001.mp3"),
    ("Fooladvand / Hedayatfar", "http://dl.anhar.ir/quran/tarjome-hedayatfar/001.mp3", "https://everyayah.com/data/translations/Fooladvand_Hedayatfar_40Kbps/001001.mp3"),
    ("Makarem / Kabiri", "http://dl.anhar.ir/quran/tarjome-kabiri/001.mp3", "https://everyayah.com/data/translations/Makarem_Kabiri_16Kbps/001001.mp3"),
    ("Ibrahim Walk (English)", "https://download.quranicaudio.com/quran/ibrahim_walk/001.mp3", "https://everyayah.com/data/English/Sahih_Intnl_Ibrahim_Walk_192kbps/001001.mp3"),
]

for label, u1, u2 in iranian_candidates:
    ok1 = check_url(u1)
    ok2 = check_url(u2)
    print(f"Candidate -> [{label}] | URL1: {ok1} | URL2: {ok2}")
