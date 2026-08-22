import sqlite3
import urllib.request
import json
import os
import sys

def build_quran_database():
    print("🚀 Starting Quran Database Generation...")
    
    # 1. API Endpoints
    url = "https://api.alquran.cloud/v1/quran/quran-uthmani,fa.ansarian"
    
    print(f"📥 Fetching full Quran payload from: {url}")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    with urllib.request.urlopen(req) as response:
        if response.status != 200:
            print(f"❌ Failed to fetch data: HTTP {response.status}")
            sys.exit(1)
        raw_data = response.read().decode('utf-8')
        payload = json.loads(raw_data)
        
    if payload.get("code") != 200 or "data" not in payload:
        print("❌ Invalid API response payload!")
        sys.exit(1)
        
    print("✅ Quran payload downloaded successfully!")
    
    # Extract Uthmani Arabic edition and Persian Ansarian edition
    data = payload["data"]
    arabic_edition = data[0]     # quran-uthmani
    persian_edition = data[1]    # fa.ansarian
    
    # Ensure assets/database directory exists
    output_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "database")
    os.makedirs(output_dir, exist_ok=True)
    db_path = os.path.join(output_dir, "quran.db")
    
    # Delete old database if exists
    if os.path.exists(db_path):
        os.remove(db_path)
        print(f"🗑️ Removed existing database at {db_path}")

    # 2. Connect to SQLite
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Enable WAL mode for performance
    cursor.execute("PRAGMA journal_mode = WAL;")
    
    # 3. Create Tables
    print("🔨 Creating Database Tables & Indexes...")
    
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS surahs (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        english_name TEXT NOT NULL,
        english_name_translation TEXT NOT NULL,
        number_of_ayahs INTEGER NOT NULL,
        revelation_type TEXT NOT NULL,
        start_page INTEGER NOT NULL,
        start_juz INTEGER NOT NULL
    );
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS ayahs (
        id INTEGER PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        number_in_surah INTEGER NOT NULL,
        text_uthmani TEXT NOT NULL,
        page INTEGER NOT NULL,
        juz INTEGER NOT NULL,
        hizb_quarter INTEGER NOT NULL,
        sajdah INTEGER DEFAULT 0,
        FOREIGN KEY (surah_number) REFERENCES surahs (id) ON DELETE CASCADE
    );
    """)
    
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_ayahs_surah ON ayahs(surah_number);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_ayahs_page ON ayahs(page);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_ayahs_juz ON ayahs(juz);")

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS translation_editions (
        identifier TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        language TEXT NOT NULL,
        author TEXT,
        is_downloaded INTEGER DEFAULT 1
    );
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        translation_id TEXT NOT NULL,
        ayah_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        FOREIGN KEY (translation_id) REFERENCES translation_editions (identifier) ON DELETE CASCADE,
        FOREIGN KEY (ayah_id) REFERENCES ayahs (id) ON DELETE CASCADE
    );
    """)

    cursor.execute("CREATE INDEX IF NOT EXISTS idx_translations_lookup ON translations(translation_id, ayah_id);")

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        page_number INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT,
        created_at INTEGER NOT NULL
    );
    """)

    # 4. Insert Translation Edition Metadata
    cursor.execute("""
    INSERT INTO translation_editions (identifier, name, language, author, is_downloaded)
    VALUES ('fa.ansarian', 'استاد انصاریان', 'fa', 'حسین انصاریان', 1);
    """)

    # 5. Populate Surahs, Ayahs, and Translations
    print("📦 Populating Surahs, Ayahs, and Translations...")
    
    surahs_data = arabic_edition["surahs"]
    persian_surahs = persian_edition["surahs"]
    
    total_ayah_count = 0
    total_translation_count = 0

    for i in range(len(surahs_data)):
        surah = surahs_data[i]
        p_surah = persian_surahs[i]
        
        surah_num = surah["number"]
        surah_name = surah["name"]
        english_name = surah["englishName"]
        english_name_translation = surah["englishNameTranslation"]
        number_of_ayahs = surah["numberOfAyahs"]
        revelation_type = surah["revelationType"]
        
        # Determine start page and start juz from the 1st ayah
        first_ayah = surah["ayahs"][0]
        start_page = first_ayah["page"]
        start_juz = first_ayah["juz"]
        
        cursor.execute("""
        INSERT INTO surahs (id, name, english_name, english_name_translation, number_of_ayahs, revelation_type, start_page, start_juz)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """, (surah_num, surah_name, english_name, english_name_translation, number_of_ayahs, revelation_type, start_page, start_juz))
        
        # Populate Ayahs & Translations for this surah
        for j in range(len(surah["ayahs"])):
            ayah = surah["ayahs"][j]
            p_ayah = p_surah["ayahs"][j]
            
            global_ayah_id = ayah["number"]
            number_in_surah = ayah["numberInSurah"]
            text_uthmani = ayah["text"]
            page = ayah["page"]
            juz = ayah["juz"]
            hizb_quarter = ayah["hizbQuarter"]
            
            # Sajdah calculation: False -> 0, True -> 1 (Recommended) or 2 (Obligatory)
            sajda_val = 0
            sajda_raw = ayah.get("sajda", False)
            if isinstance(sajda_raw, dict):
                sajda_val = 2 if sajda_raw.get("obligatory", False) else 1
            elif isinstance(sajda_raw, bool) and sajda_raw:
                sajda_val = 1
                
            cursor.execute("""
            INSERT INTO ayahs (id, surah_number, number_in_surah, text_uthmani, page, juz, hizb_quarter, sajdah)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
            """, (global_ayah_id, surah_num, number_in_surah, text_uthmani, page, juz, hizb_quarter, sajda_val))
            
            total_ayah_count += 1
            
            # Insert Translation Text
            translation_text = p_ayah["text"]
            cursor.execute("""
            INSERT INTO translations (translation_id, ayah_id, text)
            VALUES ('fa.ansarian', ?, ?);
            """, (global_ayah_id, translation_text))
            
            total_translation_count += 1

    conn.commit()
    conn.close()
    
    db_size_mb = os.path.getsize(db_path) / (1024 * 1024)
    print("\n🎉 SUCCESS! Database built successfully!")
    print(f"📍 Database File Path: {db_path}")
    print(f"📊 Database Size: {db_size_mb:.2f} MB")
    print(f"✨ Total Surahs Inserted: {len(surahs_data)}")
    print(f"✨ Total Ayahs Inserted: {total_ayah_count}")
    print(f"✨ Total Translations Inserted: {total_translation_count}")

if __name__ == "__main__":
    build_quran_database()
