import urllib.request
import re
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def check_url(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=4, context=ctx) as r:
            return r.status == 200
    except:
        return False

print("=== 1. EVERYAYAH ALL TRANSLATION FOLDERS ===")
everyayah_url = "https://everyayah.com/data/translations/"
req = urllib.request.Request(everyayah_url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=8, context=ctx) as r:
        html = r.read().decode('utf-8')
        folders = re.findall(r'href="([^"]+)"', html)
        for f in folders:
            if f.endswith('/'):
                subfolder = f"translations/{f.rstrip('/')}"
                test_u = f"https://everyayah.com/data/{subfolder}/001001.mp3"
                ok = check_url(test_u)
                print(f"[EveryAyah] {subfolder} | Working: {ok}")
except Exception as e:
    print(f"EveryAyah translations error: {e}")

print("\n=== 2. IRANIAN HOSTS FOR PERSIAN TRANSLATIONS ===")
iranian_hosts = [
    ("Persian - Fooladvand & Hedayatfar (EveryAyah 40k)", "translations/Fooladvand_Hedayatfar_40Kbps", "https://everyayah.com/data/translations/Fooladvand_Hedayatfar_40Kbps/001001.mp3"),
    ("Persian - Makarem & Kabiri (EveryAyah 16k)", "translations/Makarem_Kabiri_16Kbps", "https://everyayah.com/data/translations/Makarem_Kabiri_16Kbps/001001.mp3"),
    ("Persian - Bahrampour (Anhar/Aviny)", "http://dl.anhar.ir/quran/bahrampour/{surah_2digit}.mp3", "http://dl.anhar.ir/quran/bahrampour/01.mp3"),
    ("Persian - Haddad Adel (Anhar/Aviny)", "http://dl.anhar.ir/quran/haddad-adel/{surah_2digit}.mp3", "http://dl.anhar.ir/quran/haddad-adel/01.mp3"),
    ("Persian - Khorramshahi (Anhar/Aviny)", "http://dl.anhar.ir/quran/khorramshahi/{surah_2digit}.mp3", "http://dl.anhar.ir/quran/khorramshahi/01.mp3"),
]

for label, subfolder, sample in iranian_hosts:
    ok = check_url(sample)
    print(f"[Iranian Host] {label} | Working: {ok} | Sample: {sample}")

print("\n=== 3. ALQURAN CLOUD OTHER LANGUAGES AUDIO TRANSLATIONS ===")
url = "https://api.alquran.cloud/v1/edition?format=audio"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=8, context=ctx) as r:
        data = json.loads(r.read().decode('utf-8'))['data']
        for ed in data:
            lang = ed.get('language')
            ident = ed.get('identifier')
            name = ed.get('name')
            type_ = ed.get('type')
            if type_ == 'translation' or lang not in ['ar']:
                sample = f"https://cdn.islamic.network/quran/audio/128/{ident}/1.mp3"
                ok = check_url(sample)
                print(f"[AlQuranCloud] {lang} | {ident} | {name} | Working: {ok}")
except Exception as e:
    print(f"AlQuranCloud error: {e}")
