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
            return resp.status == 200
    except Exception as e:
        return False

# 1. Test AlQuran Cloud Editions (Persian & English)
print("=== ALQURAN CLOUD API (AYAH BY AYAH AUDIO) ===")
url = "https://api.alquran.cloud/v1/edition?format=audio"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req, timeout=10, context=ctx) as resp:
    data = json.loads(resp.read().decode('utf-8'))
    editions = data.get('data', [])
    for ed in editions:
        lang = ed.get('language')
        identifier = ed.get('identifier')
        name = ed.get('name', '')
        englishName = ed.get('englishName', '')
        
        if lang in ['fa', 'en']:
            sample_url = f"https://cdn.islamic.network/quran/audio/128/{identifier}/1.mp3"
            ok = check_url(sample_url)
            print(f"ID: {identifier} | Lang: {lang} | Name: {englishName} | Working: {ok}")
            print(f"   URL: {sample_url}")

# 2. Test EveryAyah Audio Translations Folders
print("\n=== EVERYAYAH FOLDERS (PERSIA & ENGLISH) ===")
everyayah_folders = [
    # Persian
    ("fa.hedayatfar", "https://everyayah.com/data/fa.hedayatfar_hedayatfar_64kbps/001001.mp3"),
    ("fa.hedayatfar40", "https://everyayah.com/data/fa.fooladvand_hedayatfar_40kbps/001001.mp3"),
    ("fa.kabiri", "https://everyayah.com/data/fa.makarem_kabiri_64kbps/001001.mp3"),
    
    # English
    ("Ibrahim_Walk_192kbps_2008", "https://everyayah.com/data/Ibrahim_Walk_192kbps_2008/001001.mp3"),
    ("Ibrahim_Walk_32kbps", "https://everyayah.com/data/Ibrahim_Walk_32kbps/001001.mp3"),
    ("en.walk", "https://everyayah.com/data/en.walk/001001.mp3"),
]

for name, url in everyayah_folders:
    ok = check_url(url)
    print(f"EveryAyah Folder [{name}]: {url} -> Working: {ok}")

# 3. Test Iranian Servers (Aviny, Anhar, Tebyan, Radio Quran, Quran.ir)
print("\n=== IRANIAN SERVERS (AVINY, ANHAR, TEBYAN, RADIO QURAN) ===")
iranian_audio_samples = [
    # Persian Hedayatfar (Fooladvand translation)
    ("Fooladvand - Hedayatfar (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-hedayatfar/001.mp3"),
    ("Fooladvand - Hedayatfar (Anhar)", "http://dl.anhar.ir/quran/tarjome-hedayatfar/001.mp3"),
    ("Fooladvand - Hedayatfar (Tebyan)", "http://sound.tebyan.net/music/quran/tarjome/hedayatfar/001.mp3"),
    
    # Makarem Kabiri
    ("Makarem - Kabiri (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-kabiri/001.mp3"),
    ("Makarem - Kabiri (Anhar)", "http://dl.anhar.ir/quran/tarjome-kabiri/001.mp3"),
    
    # English Audio Translation (Pickthall / Sahih International)
    ("Sahih International English (Quranicaudio)", "https://download.quranicaudio.com/quran/ibrahim_walk/001.mp3"),
    ("Sahih International English (MP3Quran)", "https://server12.mp3quran.net/walk/001.mp3"),
]

for title, url in iranian_audio_samples:
    ok = check_url(url)
    print(f"[{title}]: {url} -> Working: {ok}")
