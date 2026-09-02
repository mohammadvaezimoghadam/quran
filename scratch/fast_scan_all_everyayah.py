import urllib.request
import re
import ssl
from concurrent.futures import ThreadPoolExecutor

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def check_folder(f):
    f_clean = f.strip('/')
    if not f_clean or f_clean.startswith('#') or f_clean.startswith('?') or f_clean.startswith('.'):
        return None
    test_url = f"https://everyayah.com/data/{f_clean}/001001.mp3"
    req = urllib.request.Request(test_url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=3, context=ctx) as r:
            if r.status == 200:
                return (f_clean, test_url)
    except:
        pass
    return None

url = "https://everyayah.com/data/"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=8, context=ctx) as r:
        html = r.read().decode('utf-8')
        folders = re.findall(r'href="([^"]+)"', html)
        
        with ThreadPoolExecutor(max_workers=20) as executor:
            results = executor.map(check_folder, set(folders))
            
        print("=== WORKING EVERYAYAH FOLDERS ===")
        for res in sorted(filter(None, results)):
            print(f"FOLDER: {res[0]} -> {res[1]}")
except Exception as e:
    print(f"Error: {e}")
