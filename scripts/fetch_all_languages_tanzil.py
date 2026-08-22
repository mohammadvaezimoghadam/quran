import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("Fetching complete translation catalog from Fawaz Ahmed / Tanzil / AlQuran Cloud...")

# 1. Fawaz Ahmed / Tanzil Repository Editions List
url = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions.json"
try:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        
        # Group by language
        lang_map = {}
        for key, info in data.items():
            lang = info.get('language', 'Unknown')
            name = info.get('name', '')
            author = info.get('author', '')
            if lang not in lang_map:
                lang_map[lang] = []
            lang_map[lang].append({'name': name, 'author': author})

        total_editions = len(data)
        total_languages = len(lang_map)
        
        print(f"\nTOTAL TRANSLATIONS/EDITIONS AVAILABLE: {total_editions}")
        print(f"TOTAL LANGUAGES SUPPORTED: {total_languages}\n")
        
        print("=== BREAKDOWN BY LANGUAGE (Top & Popular Languages) ===")
        # Sort by number of translations
        sorted_langs = sorted(lang_map.items(), key=lambda x: len(x[1]), reverse=True)
        for lang, editions in sorted_langs:
            print(f"• {lang.capitalize()}: {len(editions)} translations")
            # Show up to 5 authors per language
            for ed in editions[:5]:
                print(f"   - {ed['author']} ({ed['name']})")
            if len(editions) > 5:
                print(f"   - ...and {len(editions) - 5} more")
            print()

except Exception as e:
    print(f"Error: {e}")
