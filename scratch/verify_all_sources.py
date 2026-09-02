import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def test_url(label, url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=5, context=ctx) as r:
            size = r.headers.get('Content-Length')
            print(f"[OK] {label}")
            print(f"     URL: {url}")
            print(f"     Status: {r.status} | Size: {size} bytes\n")
            return True
    except Exception as e:
        print(f"[FAIL] {label}: {e}\n")
        return False

print("=========================================================")
print("=== 1. AYAH-BY-AYAH AUDIO TRANSLATIONS ===")
print("=========================================================")

# Persian Ayah-by-Ayah
test_url(
    "Persian - Fooladvand (Translation: Fooladvand | Speaker: Ismail Hedayatfar)",
    "https://everyayah.com/data/translations/Fooladvand_Hedayatfar_40Kbps/001001.mp3"
)
test_url(
    "Persian - Makarem Shirazi (Translation: Makarem Shirazi | Speaker: Mohammad Reza Kabiri)",
    "https://everyayah.com/data/translations/Makarem_Kabiri_16Kbps/001001.mp3"
)

# English Ayah-by-Ayah
test_url(
    "English - Sahih International (Translation: Sahih International | Speaker: Ibrahim Walk)",
    "https://everyayah.com/data/English/Sahih_Intnl_Ibrahim_Walk_192kbps/001001.mp3"
)

print("=========================================================")
print("=== 2. SURAH-BY-SURAH AUDIO TRANSLATIONS ===")
print("=========================================================")

# Persian Surah-by-Surah
test_url(
    "Persian Surah - Hedayatfar (Anhar Host)",
    "http://dl.anhar.ir/quran/tarjome-hedayatfar/001.mp3"
)
test_url(
    "Persian Surah - Kabiri (Anhar Host)",
    "http://dl.anhar.ir/quran/tarjome-kabiri/001.mp3"
)

# English Surah-by-Surah
test_url(
    "English Surah - Ibrahim Walk (Quranicaudio CDN)",
    "https://download.quranicaudio.com/quran/ibrahim_walk/001.mp3"
)
test_url(
    "English Surah - Sahih International (MP3Quran Server)",
    "https://server12.mp3quran.net/walk/001.mp3"
)
