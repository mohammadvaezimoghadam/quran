import urllib.request
import json
import ssl
import sys

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def check(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=3, context=ctx) as r:
            return r.status == 200
    except:
        return False

print("=== ALQURAN CLOUD API (PERS Persian & ENG English) ===")
try:
    req = urllib.request.Request("https://api.alquran.cloud/v1/edition?format=audio", headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=5, context=ctx) as r:
        data = json.loads(r.read().decode('utf-8'))['data']
        for ed in data:
            lang = ed.get('language')
            ident = ed.get('identifier')
            name = ed.get('name')
            if lang in ['fa', 'en']:
                url = f"https://cdn.islamic.network/quran/audio/128/{ident}/1.mp3"
                ok = check(url)
                print(f"[{lang.upper()}] {ident} | {name} | Working: {ok}")
                print(f"      URL Template: https://cdn.islamic.network/quran/audio/128/{ident}/{{ayah_global_index}}.mp3")
except Exception as e:
    print(f"AlQuran Cloud Error: {e}")

print("\n=== EVERYAYAH AUDIO TRANSLATIONS ===")
ea_samples = [
    ("Persian - Fooladvand & Hedayatfar", "https://everyayah.com/data/fa.hedayatfar_hedayatfar_64kbps/001001.mp3", "https://everyayah.com/data/fa.hedayatfar_hedayatfar_64kbps/{surah_3digit}{ayah_3digit}.mp3"),
    ("Persian - Makarem & Kabiri", "https://everyayah.com/data/fa.makarem_kabiri_64kbps/001001.mp3", "https://everyayah.com/data/fa.makarem_kabiri_64kbps/{surah_3digit}{ayah_3digit}.mp3"),
    ("English - Ibrahim Walk (Sahih Int)", "https://everyayah.com/data/Ibrahim_Walk_192kbps_2008/001001.mp3", "https://everyayah.com/data/Ibrahim_Walk_192kbps_2008/{surah_3digit}{ayah_3digit}.mp3"),
    ("English - Ibrahim Walk (32kbps)", "https://everyayah.com/data/Ibrahim_Walk_32kbps/001001.mp3", "https://everyayah.com/data/Ibrahim_Walk_32kbps/{surah_3digit}{ayah_3digit}.mp3"),
]

for label, url, tmpl in ea_samples:
    ok = check(url)
    print(f"[{label}]: Working: {ok} | Template: {tmpl}")

print("\n=== MP3QURAN & FULL SURAH AUDIO TRANSLATIONS ===")
surah_samples = [
    ("Persian - Hedayatfar (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-hedayatfar/001.mp3", "http://dl.aviny.com/voice/quran/tarjome-hedayatfar/{surah_3digit}.mp3"),
    ("Persian - Kabiri (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-kabiri/001.mp3", "http://dl.aviny.com/voice/quran/tarjome-kabiri/{surah_3digit}.mp3"),
    ("English - Ibrahim Walk (MP3Quran)", "https://server12.mp3quran.net/walk/001.mp3", "https://server12.mp3quran.net/walk/{surah_3digit}.mp3"),
    ("English - Sahih International (Quranicaudio)", "https://download.quranicaudio.com/quran/ibrahim_walk/001.mp3", "https://download.quranicaudio.com/quran/ibrahim_walk/{surah_3digit}.mp3"),
]

for label, url, tmpl in surah_samples:
    ok = check(url)
    print(f"[{label}]: Working: {ok} | Template: {tmpl}")
