import urllib.request
import json

languages = ['ar', 'az', 'de', 'en', 'es', 'fr', 'it', 'ku', 'nl', 'ps', 'ru', 'sq', 'tr', 'ur']

for lang in languages:
    url = f"https://api.quran.com/api/v4/verses/by_chapter/1?words=true&word_fields=translation&language={lang}"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            returned_lang = data['verses'][0]['words'][0]['translation']['language_name']
            print(f"{lang} -> {returned_lang}")
    except Exception as e:
        print(f"Error for {lang}: {e}")
