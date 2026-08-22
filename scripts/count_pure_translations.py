import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.json"
try:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        
        # Filter ONLY pure translations (exclude transliteration, tafsir, or arabic quran texts)
        pure_translations = {}
        for key, info in data.items():
            name = info.get('name', '').lower()
            comments = info.get('comments', '').lower()
            
            # Exclude transliteration, tafsir, or original arabic text
            if 'transliteration' in name or 'transliteration' in comments:
                continue
            if 'tafsir' in name or 'tafsir' in comments:
                continue
            if info.get('language') == 'Arabic' and 'quran' in name:
                continue
                
            lang = info.get('language', 'Unknown')
            if lang not in pure_translations:
                pure_translations[lang] = []
            pure_translations[lang].append(info)

        total_pure = sum(len(v) for v in pure_translations.values())
        
        print(f"=== PURE TRANSLATIONS (ترجمه خالص بدون تفسیر و آواشناسی) ===")
        print(f"Total Pure Translations: {total_pure}")
        print(f"Total Languages: {len(pure_translations)}\n")
        
        # Sort languages by number of pure translations
        sorted_langs = sorted(pure_translations.items(), key=lambda x: len(x[1]), reverse=True)
        for lang, editions in sorted_langs:
            unique_authors = set(e.get('author') for e in editions if e.get('author'))
            print(f"• {lang}: {len(editions)} ترجمه (از {len(unique_authors)} مترجم مختلف)")
            for a in list(unique_authors)[:4]:
                print(f"   - {a}")
            print()

except Exception as e:
    print(f"Error: {e}")
