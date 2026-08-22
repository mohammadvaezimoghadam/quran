const sqlite3 = require('sqlite3').verbose();
const https = require('https');
const fs = require('fs');
const path = require('path');

function fetchJson(url) {
    return new Promise((resolve, reject) => {
        https.get(url, (res) => {
            if (res.statusCode !== 200) {
                reject(new Error(`HTTP Error: ${res.statusCode} for ${url}`));
                return;
            }
            let rawData = '';
            res.on('data', (chunk) => rawData += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(rawData));
                } catch (e) {
                    reject(e);
                }
            });
        }).on('error', reject);
    });
}

async function main() {
    console.log("🚀 Starting Quran Database Generation...");

    const arabicUrl = "https://api.alquran.cloud/v1/quran/quran-uthmani";
    const persianUrl = "https://api.alquran.cloud/v1/quran/fa.ansarian";

    console.log(`📥 Fetching Arabic Uthmani payload...`);
    const arabicPayload = await fetchJson(arabicUrl);
    
    console.log(`📥 Fetching Persian Ansarian Translation payload...`);
    const persianPayload = await fetchJson(persianUrl);

    if (arabicPayload.code !== 200 || !arabicPayload.data || !arabicPayload.data.surahs) {
        console.error("❌ Invalid Arabic API payload!");
        process.exit(1);
    }

    if (persianPayload.code !== 200 || !persianPayload.data || !persianPayload.data.surahs) {
        console.error("❌ Invalid Persian API payload!");
        process.exit(1);
    }

    console.log("✅ Both Quran payloads downloaded successfully!");

    const surahsData = arabicPayload.data.surahs;
    const persianSurahs = persianPayload.data.surahs;

    const outputDir = path.join(__dirname, "..", "assets", "database");
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    const dbPath = path.join(outputDir, "quran.db");
    if (fs.existsSync(dbPath)) {
        fs.unlinkSync(dbPath);
        console.log(`🗑️ Removed old database at ${dbPath}`);
    }

    const db = new sqlite3.Database(dbPath);

    db.serialize(() => {
        console.log("🔨 Creating Database Tables & Indexes...");

        db.run("PRAGMA journal_mode = WAL;");

        // 1. Table: surahs
        db.run(`
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
        `);

        // 2. Table: ayahs
        db.run(`
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
        `);

        db.run("CREATE INDEX IF NOT EXISTS idx_ayahs_surah ON ayahs(surah_number);");
        db.run("CREATE INDEX IF NOT EXISTS idx_ayahs_page ON ayahs(page);");
        db.run("CREATE INDEX IF NOT EXISTS idx_ayahs_juz ON ayahs(juz);");

        // 3. Table: translation_editions
        db.run(`
            CREATE TABLE IF NOT EXISTS translation_editions (
                identifier TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                language TEXT NOT NULL,
                author TEXT,
                is_downloaded INTEGER DEFAULT 1
            );
        `);

        // 4. Table: translations
        db.run(`
            CREATE TABLE IF NOT EXISTS translations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                translation_id TEXT NOT NULL,
                ayah_id INTEGER NOT NULL,
                text TEXT NOT NULL,
                FOREIGN KEY (translation_id) REFERENCES translation_editions (identifier) ON DELETE CASCADE,
                FOREIGN KEY (ayah_id) REFERENCES ayahs (id) ON DELETE CASCADE
            );
        `);

        db.run("CREATE INDEX IF NOT EXISTS idx_translations_lookup ON translations(translation_id, ayah_id);");

        // 5. Table: bookmarks
        db.run(`
            CREATE TABLE IF NOT EXISTS bookmarks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                surah_number INTEGER NOT NULL,
                ayah_number INTEGER NOT NULL,
                page_number INTEGER NOT NULL,
                type TEXT NOT NULL,
                title TEXT,
                created_at INTEGER NOT NULL
            );
        `);

        // 6. Table: recitation_styles
        db.run(`
            CREATE TABLE IF NOT EXISTS recitation_styles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                code TEXT NOT NULL UNIQUE,
                name TEXT NOT NULL
            );
        `);

        // 7. Table: reciters
        db.run(`
            CREATE TABLE IF NOT EXISTS reciters (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                identifier TEXT NOT NULL UNIQUE,
                name TEXT NOT NULL,
                english_name TEXT NOT NULL,
                arabic_name TEXT,
                subfolder TEXT NOT NULL,
                bitrate TEXT DEFAULT '128kbps',
                style_id INTEGER NOT NULL,
                FOREIGN KEY (style_id) REFERENCES recitation_styles (id) ON DELETE CASCADE
            );
        `);

        // Insert Translation Edition Metadata
        db.run(`
            INSERT INTO translation_editions (identifier, name, language, author, is_downloaded)
            VALUES ('fa.ansarian', 'استاد انصاریان', 'fa', 'حسین انصاریان', 1);
        `);

        // Insert Recitation Styles
        db.run(`
            INSERT INTO recitation_styles (id, code, name) VALUES
            (1, 'murattal', 'ترتیل'),
            (2, 'mujawwad', 'مجود'),
            (3, 'moallim', 'آموزشی (معلم)'),
            (4, 'translation', 'ترجمه صوتی');
        `);

        // Insert Verified Reciters Data
        db.run(`
            INSERT INTO reciters (identifier, name, english_name, arabic_name, subfolder, bitrate, style_id) VALUES
            ('parhizgar_48kbps', 'استاد شهریار پرهیزگار', 'Parhizgar', 'شهریار پرهیزگار', 'Parhizgar_48kbps', '48kbps', 1),
            ('alafasy_128kbps', 'استاد مشاری العفاسی', 'Mishary Alafasy', 'مشاري العفاسي', 'Alafasy_128kbps', '128kbps', 1),
            ('abdulsamad_murattal_192kbps', 'استاد عبدالباسط (ترتیل)', 'Abdul Basit (Murattal)', 'عبدالباسط عبدالصمد', 'Abdul_Basit_Murattal_192kbps', '192kbps', 1),
            ('abdulsamad_mujawwad_128kbps', 'استاد عبدالباسط (مجود)', 'Abdul Basit (Mujawwad)', 'عبدالباسط عبدالصمد', 'Abdul_Basit_Mujawwad_128kbps', '128kbps', 2),
            ('minshawy_murattal_128kbps', 'استاد محمد صدیق منشاوی (ترتیل)', 'Minshawy (Murattal)', 'محمد صديق المنشاوي', 'Minshawy_Murattal_128kbps', '128kbps', 1),
            ('minshawy_mujawwad_192kbps', 'استاد محمد صدیق منشاوی (مجود)', 'Minshawy (Mujawwad)', 'محمد صديق المنشاوي', 'Minshawy_Mujawwad_192kbps', '192kbps', 2),
            ('husary_128kbps', 'استاد محمود خلیل الحصری', 'Husary', 'محمود خليل الحصري', 'Husary_128kbps', '128kbps', 1),
            ('sudais_192kbps', 'استاد عبدالرحمن السدیس', 'Sudais', 'عبدالرحمن السديس', 'Abdurrahmaan_As-Sudais_192kbps', '192kbps', 1),
            ('ghamadi_40kbps', 'استاد سعد الغامدی', 'Ghamadi', 'سعد الغامدي', 'Ghamadi_40kbps', '40kbps', 1),
            ('shaatree_128kbps', 'استاد ابو بکر الشاطری', 'Abu Bakr Ash-Shaatree', 'أبو بكر الشاطري', 'Abu_Bakr_Ash-Shaatree_128kbps', '128kbps', 1),
            ('rifai_192kbps', 'استاد هانی الرفاعی', 'Hani Rifai', 'هاني الرفاعي', 'Hani_Rifai_192kbps', '192kbps', 1),
            ('hudhaify_128kbps', 'استاد علی بن عبدالرحمن الحذیفی', 'Hudhaify', 'علي بن عبدالرحمن الحذيفي', 'Hudhaify_128kbps', '128kbps', 1),
            ('shuraym_128kbps', 'استاد سعود الشریم', 'Saood ash-Shuraym', 'سعود الشريم', 'Saood_ash-Shuraym_128kbps', '128kbps', 1),
            ('maher_64kbps', 'استاد ماهر المعیقلی', 'Maher Al Muaiqly', 'ماهر المعيقلي', 'Maher_AlMuaiqly_64kbps', '64kbps', 1);
        `);

        console.log("📦 Populating Surahs, Ayahs, and Translations...");

        const insertSurahStmt = db.prepare(`
            INSERT INTO surahs (id, name, english_name, english_name_translation, number_of_ayahs, revelation_type, start_page, start_juz)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        `);

        const insertAyahStmt = db.prepare(`
            INSERT INTO ayahs (id, surah_number, number_in_surah, text_uthmani, page, juz, hizb_quarter, sajdah)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        `);

        const insertTranslationStmt = db.prepare(`
            INSERT INTO translations (translation_id, ayah_id, text)
            VALUES ('fa.ansarian', ?, ?);
        `);

        for (let i = 0; i < surahsData.length; i++) {
            const surah = surahsData[i];
            const pSurah = persianSurahs[i];

            const firstAyah = surah.ayahs[0];
            const startPage = firstAyah.page;
            const startJuz = firstAyah.juz;
            const numberOfAyahs = surah.ayahs.length;

            insertSurahStmt.run(
                surah.number,
                surah.name,
                surah.englishName,
                surah.englishNameTranslation,
                numberOfAyahs,
                surah.revelationType,
                startPage,
                startJuz
            );

            for (let j = 0; j < surah.ayahs.length; j++) {
                const ayah = surah.ayahs[j];
                const pAyah = pSurah.ayahs[j];

                let sajdaVal = 0;
                const sajdaRaw = ayah.sajda;
                if (typeof sajdaRaw === 'object' && sajdaRaw !== null) {
                    sajdaVal = sajdaRaw.obligatory ? 2 : 1;
                } else if (typeof sajdaRaw === 'boolean' && sajdaRaw) {
                    sajdaVal = 1;
                }

                insertAyahStmt.run(
                    ayah.number,
                    surah.number,
                    ayah.numberInSurah,
                    ayah.text,
                    ayah.page,
                    ayah.juz,
                    ayah.hizbQuarter,
                    sajdaVal
                );

                insertTranslationStmt.run(
                    ayah.number,
                    pAyah.text
                );
            }
        }

        insertSurahStmt.finalize();
        insertAyahStmt.finalize();
        insertTranslationStmt.finalize();

        db.get("SELECT COUNT(*) AS count FROM surahs", (err, row) => {
            console.log(`✨ Surahs Table Count: ${row.count}`);
        });

        db.get("SELECT COUNT(*) AS count FROM ayahs", (err, row) => {
            console.log(`✨ Ayahs Table Count: ${row.count}`);
        });

        db.get("SELECT COUNT(*) AS count FROM translations", (err, row) => {
            console.log(`✨ Translations Table Count: ${row.count}`);
        });

        db.get("SELECT COUNT(*) AS count FROM recitation_styles", (err, row) => {
            console.log(`✨ Recitation Styles Table Count: ${row.count}`);
        });

        db.get("SELECT COUNT(*) AS count FROM reciters", (err, row) => {
            console.log(`✨ Reciters Table Count: ${row.count}`);
        });
    });

    db.close((err) => {
        if (err) {
            console.error("❌ Error closing DB:", err);
            process.exit(1);
        }
        const stats = fs.statSync(dbPath);
        const sizeMb = (stats.size / (1024 * 1024)).toFixed(2);
        console.log("\n🎉 SUCCESS! quran.db created successfully!");
        console.log(`📍 Output Path: ${dbPath}`);
        console.log(`📊 File Size: ${sizeMb} MB`);
    });
}

main().catch(err => {
    console.error("❌ Unhandled Error:", err);
    process.exit(1);
});
