import urllib.request
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

url = "http://tanzil.net/trans/"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as resp:
    html = resp.read().decode('utf-8', errors='ignore')
    
    # Tanzil stores translations array in Javascript object trans = [...]
    trans_match = re.search(r'trans\s*=\s*(\{.*?\});', html, re.DOTALL)
    if trans_match:
        print("Found trans object JS code!")
        js_code = trans_match.group(1)
        print(js_code[:1000])
    else:
        # Search for any 'fa.' or language keys
        fa_matches = re.findall(r'fa\.[a-z0-9_]+', html)
        print("Fa matches:", set(fa_matches))
