import urllib.request
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

urls = [
    ("Persian - Fooladvand & Hedayatfar (EveryAyah)", "https://everyayah.com/data/translations/Fooladvand_Hedayatfar_40Kbps/001001.mp3"),
    ("Persian - Makarem & Kabiri (EveryAyah)", "https://everyayah.com/data/translations/Makarem_Kabiri_16Kbps/001001.mp3"),
    ("English - Sahih International & Ibrahim Walk (EveryAyah)", "https://everyayah.com/data/English/Sahih_Intnl_Ibrahim_Walk_192kbps/001001.mp3"),
]

print("=== VERIFYING EVERYAYAH AUDIO TRANSLATIONS (AYAH BY AYAH) ===")
for label, u in urls:
    req = urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=5, context=ctx) as r:
            length = r.headers.get('Content-Length')
            print(f"[OK] {label}")
            print(f"   URL: {u}")
            print(f"   Status: {r.status} | Size: {length} bytes\n")
    except Exception as e:
        print(f"[FAIL] {label}: {e}\n")
