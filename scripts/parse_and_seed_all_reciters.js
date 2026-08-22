const sqlite3 = require('sqlite3').verbose();
const https = require('https');
const path = require('path');

// Helper to map English directory names to Persian Reciter names and styles
function parseFolder(folderName) {
    const cleanFolder = folderName.replace(/\/$/, '').replace(/^data\//, '');
    let bitrate = '128kbps';
    let styleId = 1; // 1: murattal, 2: mujawwad, 3: moallim, 4: translation

    // Extract bitrate
    const bitrateMatch = cleanFolder.match(/(\d+kbps)/i);
    if (bitrateMatch) {
        bitrate = bitrateMatch[1].toLowerCase();
    }

    // Determine style
    if (/mujawwad/i.test(cleanFolder)) {
        styleId = 2;
    } else if (/muallim|teacher/i.test(cleanFolder)) {
        styleId = 3;
    } else if (/translation|english|urdu|persian|kurdish|pashto/i.test(cleanFolder)) {
        styleId = 4;
    } else {
        styleId = 1; // default murattal
    }

    // Clean English Name
    let englishName = cleanFolder
        .replace(/_\d+kbps.*/i, '')
        .replace(/_/g, ' ')
        .replace(/%20/g, ' ')
        .trim();

    // Map common reciters to beautiful Persian names
    let persianName = `استاد ${englishName}`;
    let arabicName = englishName;

    if (/Parhizgar/i.test(cleanFolder)) {
        persianName = 'استاد شهریار پرهیزگار';
        arabicName = 'شهریار پرهیزگار';
    } else if (/Alafasy/i.test(cleanFolder)) {
        persianName = 'استاد مشاری العفاسی';
        arabicName = 'مشاري العفاسي';
    } else if (/Abdul_Basit_Mujawwad/i.test(cleanFolder)) {
        persianName = 'استاد عبدالباسط (مجود)';
        arabicName = 'عبدالباسط عبدالصمد';
    } else if (/Abdul_Basit_Murattal|AbdulSamad/i.test(cleanFolder)) {
        persianName = 'استاد عبدالباسط (ترتیل)';
        arabicName = 'عبدالباسط عبدالصمد';
    } else if (/Minshawy_Mujawwad/i.test(cleanFolder)) {
        persianName = 'استاد محمد صدیق منشاوی (مجود)';
        arabicName = 'محمد صديق المنشاوي';
    } else if (/Minshawy_Murattal|Minshawi/i.test(cleanFolder)) {
        persianName = 'استاد محمد صدیق منشاوی (ترتیل)';
        arabicName = 'محمد صديق المنشاوي';
    } else if (/Husary_Muallim/i.test(cleanFolder)) {
        persianName = 'استاد محمود خلیل الحصری (آموزشی)';
        arabicName = 'محمود خليل الحصري';
    } else if (/Husary/i.test(cleanFolder)) {
        persianName = 'استاد محمود خلیل الحصری';
        arabicName = 'محمود خليل الحصري';
    } else if (/Sudais/i.test(cleanFolder)) {
        persianName = 'استاد عبدالرحمن السدیس';
        arabicName = 'عبدالرحمن السديس';
    } else if (/Ghamadi/i.test(cleanFolder)) {
        persianName = 'استاد سعد الغامدی';
        arabicName = 'سعد الغامدي';
    } else if (/Shaatree/i.test(cleanFolder)) {
        persianName = 'استاد ابو بکر الشاطری';
        arabicName = 'أبو بكر الشاطري';
    } else if (/Rifai/i.test(cleanFolder)) {
        persianName = 'استاد هانی الرفاعی';
        arabicName = 'هاني الرفاعي';
    } else if (/Hudhaify/i.test(cleanFolder)) {
        persianName = 'استاد علی بن عبدالرحمن الحذیفی';
        arabicName = 'علي بن عبدالرحمن الحذيفي';
    } else if (/Shuraym/i.test(cleanFolder)) {
        persianName = 'استاد سعود الشریم';
        arabicName = 'سعود الشريم';
    } else if (/Maher/i.test(cleanFolder)) {
        persianName = 'استاد ماهر المعیقلی';
        arabicName = 'ماهر المعيقلي';
    } else if (/Basfar/i.test(cleanFolder)) {
        persianName = 'استاد عبدالله بصفر';
        arabicName = 'عبد الله بصفر';
    } else if (/Matroud/i.test(cleanFolder)) {
        persianName = 'استاد عبدالله مطرود';
        arabicName = 'عبدالله مطرود';
    } else if (/Juhaynee/i.test(cleanFolder)) {
        persianName = 'استاد عبدالله الجهنی';
        arabicName = 'عبدالله الجهني';
    } else if (/Ajamy/i.test(cleanFolder)) {
        persianName = 'استاد احمد بن علی العجمی';
        arabicName = 'أحمد بن علي العجمي';
    } else if (/Bukhatir/i.test(cleanFolder)) {
        persianName = 'استاد صلاح بوخاطر';
        arabicName = 'صلاح بوخاطر';
    } else if (/Tablaway/i.test(cleanFolder)) {
        persianName = 'استاد محمد الطبلاوی';
        arabicName = 'محمد الطبلاوي';
    } else if (/Swayd/i.test(cleanFolder)) {
        persianName = 'استاد ایمن سوید';
        arabicName = 'أيمن سويد';
    } else if (/Khabir/i.test(cleanFolder)) {
        persianName = 'استاد کبیری';
        arabicName = 'کبیری';
    } else if (/Akhdar/i.test(cleanFolder)) {
        persianName = 'استاد ابراهیم الاخضر';
        arabicName = 'إبراهيم الأخضر';
    } else if (/Jibreel/i.test(cleanFolder)) {
        persianName = 'استاد محمد جبریل';
        arabicName = 'محمد جبريل';
    } else if (/Ayyoub/i.test(cleanFolder)) {
        persianName = 'استاد محمد ایوب';
        arabicName = 'محمد أيوب';
    } else if (/Banna/i.test(cleanFolder)) {
        persianName = 'استاد محمود علی البنا';
        arabicName = 'محمود علي البنا';
    }

    // Append bitrate indicator if multiple qualities exist
    if (bitrate && bitrate !== '128kbps') {
        persianName += ` (${bitrate})`;
    }

    const identifier = cleanFolder
        .toLowerCase()
        .replace(/%20/g, '_')
        .replace(/[^a-z0-9_]/g, '_')
        .replace(/_+/g, '_')
        .replace(/^_|_$/g, '');

    return {
        identifier: identifier,
        name: persianName,
        englishName: englishName,
        arabicName: arabicName,
        subfolder: cleanFolder,
        bitrate: bitrate,
        styleId: styleId
    };
}

async function main() {
    console.log("🌐 Fetching all folders from EveryAyah CDN...");
    
    https.get('https://everyayah.com/data/', (res) => {
        let html = '';
        res.on('data', chunk => html += chunk);
        res.on('end', () => {
            const regex = /href="([^"]+\/)"/g;
            let match;
            const folders = [];
            while ((match = regex.exec(html)) !== null) {
                const name = match[1].replace('/', '');
                if (name && !name.startsWith('?') && !name.startsWith('http') && name !== '..' && name !== '.') {
                    folders.push(name);
                }
            }

            console.log(`🎉 Found ${folders.length} EveryAyah folders!`);

            const dbPath = path.join(__dirname, "..", "assets", "database", "quran.db");
            const db = new sqlite3.Database(dbPath);

            db.serialize(() => {
                db.run("DELETE FROM reciters;");

                const stmt = db.prepare(`
                    INSERT OR REPLACE INTO reciters (identifier, name, english_name, arabic_name, subfolder, bitrate, style_id)
                    VALUES (?, ?, ?, ?, ?, ?, ?);
                `);

                let insertedCount = 0;
                folders.forEach(folder => {
                    const parsed = parseFolder(folder);
                    stmt.run(
                        parsed.identifier,
                        parsed.name,
                        parsed.englishName,
                        parsed.arabicName,
                        parsed.subfolder,
                        parsed.bitrate,
                        parsed.styleId
                    );
                    insertedCount++;
                });

                stmt.finalize();

                db.get("SELECT COUNT(*) as count FROM reciters", (err, row) => {
                    console.log(`✅ Total Reciters in Database: ${row.count}`);
                });
            });

            db.close(() => {
                console.log("🎉 ALL EveryAyah Reciters populated into quran.db successfully!");
            });
        });
    }).on('error', err => console.error("❌ Error fetching CDN index:", err));
}

main();
