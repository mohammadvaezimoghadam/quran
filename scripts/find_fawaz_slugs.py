import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.json"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as response:
    data = json.loads(response.read().decode('utf-8'))
    
    print("=== SEARCHING FAWAZ AHMED CATALOG FOR PERSAN / GERMAN TRANSLATORS ===")
    
    search_terms = ['payand', 'pour', 'halab', 'khwa', 'rez', 'rahn', 'siraj', 'kavian', 'barz', 'taher', 'malek', 'tab', 'nashr', 'maali', 'tashakor', 'amadi', 'deu', 'fas', 'ger', 'deu']
    
    for key, info in data.items():
        name = info.get('name', '').lower()
        author = info.get('author', '').lower()
        comments = info.get('comments', '').lower()
        full_str = f"{name} {author} {comments}".lower()
        
        if info.get('language') in ['Persian', 'fa', 'German', 'de'] or any(term in full_str for term in ['fas-', 'deu-']):
            print(f"Key: [{key}] | Author: {info.get('author')} | Name: {info.get('name')} | Lang: {info.get('language')}")
