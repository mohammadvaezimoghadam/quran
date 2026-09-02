import urllib.request
import re
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def check_url(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=3, context=ctx) as r:
            return r.status == 200
    except:
        return False

url = "https://everyayah.com/data/"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=10, context=ctx) as r:
        html = r.read().decode('utf-8')
        folders = re.findall(r'href="([^"]+)"', html)
        print("=== EVERYAYAH ALL ROOT FOLDERS ===")
        for f in sorted(set(folders)):
            f_clean = f.strip('/')
            if f_clean and not f_clean.startswith('#') and not f_clean.startswith('?'):
                test_url = f"https://everyayah.com/data/{f_clean}/001001.mp3"
                ok = check_url(test_url)
                if ok:
                    print(f"ROOT FOLDER WORKING: {f_clean} -> {test_url}")
except Exception as e:
    print(f"Error: {e}")
