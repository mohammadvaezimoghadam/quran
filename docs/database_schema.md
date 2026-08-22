# Quran App Offline Database Schema Specification

This document details the SQLite database schema (`quran.db`) for the Quran application, optimized for offline reading, book mode (604 pages), juz-by-juz navigation, full-text search, multi-translation support, and reciter audio playback.

---

## 1. Overview & Architecture Design

To support **100% offline functionality**, instantaneous search (<10ms), and the flexibility to switch or add multiple translations (Persian Ansarian, Fooladvand, Makarem, English, etc.) and reciters (Parhizgar, Alafasy, Abdul Basit, Minshawy, etc.), the database is split into normalized entities:

1. **`surahs`**: 114 Quranic Surahs with revelation details and start page/juz indicators.
2. **`ayahs`**: 6,236 Ayahs with Uthmani Arabic text and metadata (Page 1-604, Juz 1-30, Hizb 1-240, Sajdah).
3. **`translation_editions`**: List of available translation metadata (e.g., Ansarian, Fooladvand, Sahih International).
4. **`translations`**: Ayah translation texts linked to Ayah IDs and Translation Identifiers.
5. **`bookmarks`**: User reading progress, last read page/ayah, and saved bookmarks.
6. **`recitation_styles`**: Master lookup table for recitation styles (Murattal, Mujawwad, Teacher, Audio Translation).
7. **`reciters`**: Quran reciters and their EveryAyah CDN subfolders, bitrates, and style relations.

---

## 2. Table Schema Definitions (SQL)

### 2.1. Table: `surahs` (114 rows)
```sql
CREATE TABLE IF NOT EXISTS surahs (
    id INTEGER PRIMARY KEY,                  -- Surah number (1 to 114)
    name TEXT NOT NULL,                      -- Arabic name (e.g., سُورَةُ ٱلْبَقَرَةِ)
    english_name TEXT NOT NULL,              -- Transliterated name (e.g., Al-Baqara)
    english_name_translation TEXT NOT NULL,  -- English meaning (e.g., The Cow)
    number_of_ayahs INTEGER NOT NULL,        -- Total ayahs in surah (e.g., 286)
    revelation_type TEXT NOT NULL,           -- "Meccan" or "Medinan"
    start_page INTEGER NOT NULL,             -- Page number in Uthmani Mushaf (1 to 604)
    start_juz INTEGER NOT NULL               -- Juz number where surah starts (1 to 30)
);
```

### 2.2. Table: `ayahs` (6,236 rows)
```sql
CREATE TABLE IF NOT EXISTS ayahs (
    id INTEGER PRIMARY KEY,                  -- Global Ayah number (1 to 6236)
    surah_number INTEGER NOT NULL,           -- Surah number (1 to 114, FK to surahs.id)
    number_in_surah INTEGER NOT NULL,        -- Ayah number within Surah (e.g., 255)
    text_uthmani TEXT NOT NULL,              -- Arabic text in Uthmani script with diacritics
    page INTEGER NOT NULL,                   -- Uthmani Mushaf Page number (1 to 604)
    juz INTEGER NOT NULL,                    -- Juz number (1 to 30)
    hizb_quarter INTEGER NOT NULL,           -- Hizb Quarter number (1 to 240)
    sajdah INTEGER DEFAULT 0,                -- 0 = None, 1 = Recommended, 2 = Obligatory
    FOREIGN KEY (surah_number) REFERENCES surahs (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_ayahs_surah ON ayahs(surah_number);
CREATE INDEX IF NOT EXISTS idx_ayahs_page ON ayahs(page);
CREATE INDEX IF NOT EXISTS idx_ayahs_juz ON ayahs(juz);
```

### 2.3. Table: `translation_editions`
```sql
CREATE TABLE IF NOT EXISTS translation_editions (
    identifier TEXT PRIMARY KEY,             -- Unique key (e.g., 'fa.ansarian', 'fa.fooladvand')
    name TEXT NOT NULL,                      -- Display name (e.g., 'استاد انصاریان')
    language TEXT NOT NULL,                  -- Language code (e.g., 'fa', 'en')
    author TEXT,                             -- Translator name
    is_downloaded INTEGER DEFAULT 1          -- 1 if available in local DB, 0 if remote
);
```

### 2.4. Table: `translations`
```sql
CREATE TABLE IF NOT EXISTS translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    translation_id TEXT NOT NULL,            -- FK to translation_editions.identifier
    ayah_id INTEGER NOT NULL,                -- Global Ayah ID (1 to 6236, FK to ayahs.id)
    text TEXT NOT NULL,                      -- Translated text string
    FOREIGN KEY (translation_id) REFERENCES translation_editions (identifier) ON DELETE CASCADE,
    FOREIGN KEY (ayah_id) REFERENCES ayahs (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_translations_lookup ON translations(translation_id, ayah_id);
```

### 2.5. Table: `bookmarks`
```sql
CREATE TABLE IF NOT EXISTS bookmarks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    surah_number INTEGER NOT NULL,
    ayah_number INTEGER NOT NULL,
    page_number INTEGER NOT NULL,
    type TEXT NOT NULL,                      -- 'last_read' or 'bookmark'
    title TEXT,                              -- Optional custom note/title
    created_at INTEGER NOT NULL              -- Unix timestamp (milliseconds)
);
```

### 2.6. Table: `recitation_styles`
```sql
CREATE TABLE IF NOT EXISTS recitation_styles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,               -- Code identifier (e.g., 'murattal', 'mujawwad', 'moallim')
    name TEXT NOT NULL                       -- Display name in Persian (e.g., 'ترتیل', 'مجود', 'آموزشی')
);
```

### 2.7. Table: `reciters`
```sql
CREATE TABLE IF NOT EXISTS reciters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    identifier TEXT NOT NULL UNIQUE,          -- Unique reciter key (e.g., 'parhizgar_48kbps')
    name TEXT NOT NULL,                       -- Persian display name (e.g., 'استاد شهریار پرهیزگار')
    english_name TEXT NOT NULL,               -- English name (e.g., 'Parhizgar')
    arabic_name TEXT,                         -- Arabic name (e.g., 'شهریار پرهیزگار')
    subfolder TEXT NOT NULL,                  -- EveryAyah CDN subfolder (e.g., 'Parhizgar_48kbps')
    bitrate TEXT DEFAULT '128kbps',           -- Bitrate quality (e.g., '48kbps', '128kbps', '192kbps')
    style_id INTEGER NOT NULL,                -- FK to recitation_styles.id
    FOREIGN KEY (style_id) REFERENCES recitation_styles (id) ON DELETE CASCADE
);
```
