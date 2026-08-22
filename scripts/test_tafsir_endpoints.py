import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("==================================================")
print("=== TESTING TAFSIR API ENDPOINTS ===")
print("==================================================")

# 1. AlQuran Cloud Tafsir (e.g. ar.muyassar - Al-Tafseer Al-Muyassar)
url_alquran = "https://api.alquran.cloud/v1/ayah/1/ar.muyassar"
print(f"\n1. Testing AlQuran Cloud (Ayah 1 Tafsir): {url_alquran}")
try:
    req = urllib.request.Request(url_alquran, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        print("Response Structure:")
        print(json.dumps(data, ensure_ascii=False, indent=2)[:500])
except Exception as e:
    print(f"Error: {e}")

# 2. Quran.com Tafsir API v4 (e.g. Tafsir Ibn Kathir / Jalalayn for Surah 1 Ayah 1)
url_qurancom = "https://api.quran.com/api/v4/tafsirs/169/by_ayah/1:1"
print(f"\n2. Testing Quran.com API v4 (Surah 1:1 Tafsir): {url_qurancom}")
try:
    req = urllib.request.Request(url_qurancom, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        print("Response Structure:")
        print(json.dumps(data, ensure_ascii=False, indent=2)[:500])
except Exception as e:
    print(f"Error: {e}")

# 3. Fawaz Ahmed Tafsir API (e.g. Tafsir Al-Waseet or Jalalayn)
url_fawaz = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/ara-tafsir-al-wasit/1/1.json"
print(f"\n3. Testing Fawaz Ahmed Tafsir API (Surah 1 Ayah 1): {url_fawaz}")
try:
    req = urllib.request.Request(url_fawaz, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        print("Response Structure:")
        print(json.dumps(data, ensure_ascii=False, indent=2)[:500])
except Exception as e:
    print(f"Error: {e}")

print("\n==================================================")
