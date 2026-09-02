import urllib.request
import re
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = "https://everyayah.com/data/"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=10, context=ctx) as r:
        html = r.read().decode('utf-8')
        folders = re.findall(r'href="([^"]+)"', html)
        print("=== EVERYAYAH ALL FOLDERS ===")
        for f in sorted(folders):
            if 'fa' in f.lower() or 'hedayatfar' in f.lower() or 'kabiri' in f.lower() or 'fooladvand' in f.lower() or 'walk' in f.lower() or 'english' in f.lower() or 'translation' in f.lower():
                print(f)
except Exception as e:
    print(f"Error fetching EveryAyah index: {e}")
