const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, "..", "assets", "database", "quran.db");
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
    console.log("🔨 Adding recitation_styles and reciters tables to quran.db...");

    db.run("PRAGMA journal_mode = WAL;");

    // 1. Create recitation_styles
    db.run(`
        CREATE TABLE IF NOT EXISTS recitation_styles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL
        );
    `);

    // 2. Create reciters
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

    // Clear existing data if any to avoid unique constraint errors
    db.run("DELETE FROM reciters;");
    db.run("DELETE FROM recitation_styles;");

    // Insert Recitation Styles
    db.run(`
        INSERT INTO recitation_styles (id, code, name) VALUES
        (1, 'murattal', 'ترتیل'),
        (2, 'mujawwad', 'مجود'),
        (3, 'moallim', 'آموزشی (معلم)'),
        (4, 'translation', 'ترجمه صوتی');
    `);

    // Insert Reciters
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

    db.get("SELECT COUNT(*) AS count FROM recitation_styles", (err, row) => {
        console.log(`✨ Recitation Styles Count: ${row.count}`);
    });

    db.get("SELECT COUNT(*) AS count FROM reciters", (err, row) => {
        console.log(`✨ Reciters Count: ${row.count}`);
    });
});

db.close(() => {
    console.log("🎉 reciters tables added successfully to quran.db!");
});
