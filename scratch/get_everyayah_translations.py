import urllib.request
import re
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def get_links(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=10, context=ctx) as r:
            html = r.read().decode('utf-8')
            return re.findall(r'href="([^"]+)"', html)
    except Exception as e:
        print(f"Error {url}: {e}")
        return []

print("=== EVERYAYAH /data/translations/ ===")
for link in get_links("https://everyayah.com/data/translations/"):
    print("  ", link)

print("\n=== EVERYAYAH /data/English/ ===")
for link in get_links("https://everyayah.com/data/English/"):
    print("  ", link)
