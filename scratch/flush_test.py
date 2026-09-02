import urllib.request
import ssl
import sys

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

urls = [
    ("Persian Ayah - Hedayatfar (EveryAyah)", "https://everyayah.com/data/fa.hedayatfar_hedayatfar_64kbps/001001.mp3"),
    ("Persian Ayah - Fooladvand (EveryAyah)", "https://everyayah.com/data/fa.fooladvand_hedayatfar_40kbps/001001.mp3"),
    ("Persian Ayah - Makarem Kabiri (EveryAyah)", "https://everyayah.com/data/fa.makarem_kabiri_64kbps/001001.mp3"),
    ("Persian Ayah - AlQuran Cloud Hedayatfar", "https://cdn.islamic.network/quran/audio/128/fa.hedayatfar/1.mp3"),
    ("Persian Surah - Hedayatfar (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-hedayatfar/001.mp3"),
    ("Persian Surah - Kabiri (Aviny)", "http://dl.aviny.com/voice/quran/tarjome-kabiri/001.mp3"),
    ("English Ayah - Ibrahim Walk (EveryAyah 192k)", "https://everyayah.com/data/Ibrahim_Walk_192kbps_2008/001001.mp3"),
    ("English Ayah - Ibrahim Walk (EveryAyah 32k)", "https://everyayah.com/data/Ibrahim_Walk_32kbps/001001.mp3"),
    ("English Ayah - AlQuran Cloud Walk", "https://cdn.islamic.network/quran/audio/128/en.walk/1.mp3"),
    ("English Surah - Ibrahim Walk (Quranicaudio)", "https://download.quranicaudio.com/quran/ibrahim_walk/001.mp3"),
    ("English Surah - Sahih Int (MP3Quran)", "https://server12.mp3quran.net/walk/001.mp3"),
]

for label, u in urls:
    req = urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=3, context=ctx) as r:
            print(f"OK | {label} | Status: {r.status} | {u}", flush=True)
    except Exception as e:
        print(f"FAIL | {label} | Error: {e} | {u}", flush=True)
