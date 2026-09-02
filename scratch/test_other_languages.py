import urllib.request
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def test_url(label, subfolder):
    url = f"https://everyayah.com/data/{subfolder}/001001.mp3"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=5, context=ctx) as r:
            size = r.headers.get('Content-Length')
            print(f"[OK] {label}")
            print(f"     Subfolder: {subfolder}")
            print(f"     Status: {r.status} | Size: {size} bytes\n")
            return True
    except Exception as e:
        print(f"[FAIL] {label} ({subfolder}): {e}\n")
        return False

print("=== TESTING EVERYAYAH OTHER LANGUAGES (AYAH-BY-AYAH) ===")

test_url("Azerbaijani Translation", "translations/azerbaijani")
test_url("Bosnian Translation (Besim Korkut)", "translations/besim_korkut_ajet_po_ajet")
test_url("Urdu Translation (Farhat Hashmi)", "translations/urdu_farhat_hashmi")
test_url("Urdu Translation (Shamshad Ali Khan)", "translations/urdu_shamshad_ali_khan_46kbps")
test_url("Russian Translation", "translations/russian")
test_url("French Translation", "translations/french")
