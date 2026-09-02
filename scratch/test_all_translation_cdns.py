import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def check_url(url):
    req = urllib.request.Request(
        url,
        headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
        }
    )
    try:
        with urllib.request.urlopen(req, timeout=5, context=ctx) as resp:
            return resp.status, resp.headers.get('Content-Length')
    except Exception as e:
        return None, str(e)

print("=== TESTING PERSIAN & ENGLISH AUDIO TRANSLATION ENDPOINTS ===")

test_urls = [
    # --- PERSIAN (آیه‌به‌آیه - Ayah by Ayah) ---
    ("Persian (Ayah) - Hedayatfar / Fooladvand (EveryAyah HTTPS)", "https://everyayah.com/data/fa.hedayatfar_hedayatfar_64kbps/001001.mp3"),
    ("Persian (Ayah) - Hedayatfar / Fooladvand (EveryAyah HTTP)", "http://everyayah.com/data/fa.hedayatfar_hedayatfar_64kbps/001001.mp3"),
    ("Persian (Ayah) - Fooladvand 40k (EveryAyah)", "https://everyayah.com/data/fa.fooladvand_hedayatfar_40kbps/001001.mp3"),
    ("Persian (Ayah) - Makarem / Kabiri (EveryAyah)", "https://everyayah.com/data/fa.makarem_kabiri_64kbps/001001.mp3"),
    ("Persian (Ayah) - AlQuran Cloud Hedayatfar", "https://cdn.islamic.network/quran/audio/128/fa.hedayatfar/1.mp3"),
    
    # --- PERSIAN (سوره‌ای / کامل - Surah Audio) ---
    ("Persian (Surah) - Hedayatfar (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-hedayatfar/001.mp3"),
    ("Persian (Surah) - Kabiri (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-kabiri/001.mp3"),
    ("Persian (Surah) - Hedayatfar (Anhar)", "http://dl.anhar.ir/quran/tarjome-hedayatfar/001.mp3"),
    ("Persian (Surah) - Kabiri (Anhar)", "http://dl.anhar.ir/quran/tarjome-kabiri/001.mp3"),
    ("Persian (Surah) - Hedayatfar (Archive.org CDN)", "https://archive.org/download/hedayatfar-full-quran/001.mp3"),

    # --- ENGLISH (آیه‌به‌آیه - Ayah by Ayah) ---
    ("English (Ayah) - Ibrahim Walk / Sahih Int (EveryAyah HTTPS)", "https://everyayah.com/data/Ibrahim_Walk_192kbps_2008/001001.mp3"),
    ("English (Ayah) - Ibrahim Walk / Sahih Int (EveryAyah HTTP)", "http://everyayah.com/data/Ibrahim_Walk_192kbps_2008/001001.mp3"),
    ("English (Ayah) - Ibrahim Walk 32k (EveryAyah)", "https://everyayah.com/data/Ibrahim_Walk_32kbps/001001.mp3"),
    ("English (Ayah) - AlQuran Cloud Walk", "https://cdn.islamic.network/quran/audio/128/en.walk/1.mp3"),

    # --- ENGLISH (سوره‌ای / کامل - Surah Audio) ---
    ("English (Surah) - Ibrahim Walk (Quranicaudio)", "https://download.quranicaudio.com/quran/ibrahim_walk/001.mp3"),
    ("English (Surah) - Ibrahim Walk (Quranicaudio 3digit)", "https://download.quranicaudio.com/quran/ibrahim_walk/001.mp3"),
    ("English (Surah) - Ibrahim Walk (MP3Quran)", "https://server12.mp3quran.net/walk/001.mp3"),
]

for label, url in test_urls:
    status, info = check_url(url)
    print(f"[{'OK' if status == 200 else 'FAIL'}] {label}")
    print(f"     URL: {url}")
    print(f"     Status: {status} | Size/Info: {info}\n")
