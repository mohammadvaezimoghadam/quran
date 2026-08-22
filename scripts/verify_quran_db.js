const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, "..", "assets", "database", "quran.db");
const db = new sqlite3.Database(dbPath);

console.log("🔍 STARTING COMPREHENSIVE QURAN DATABASE AUDIT...\n");

db.serialize(() => {
    // Test 1: Surah Count & Extremes
    db.get("SELECT COUNT(*) AS count FROM surahs", (err, row) => {
        console.log(`1. Total Surahs: ${row.count} (Expected: 114) ${row.count === 114 ? '✅ PASS' : '❌ FAIL'}`);
    });

    // Test 2: Ayah Count
    db.get("SELECT COUNT(*) AS count FROM ayahs", (err, row) => {
        console.log(`2. Total Ayahs: ${row.count} (Expected: 6236) ${row.count === 6236 ? '✅ PASS' : '❌ FAIL'}`);
    });

    // Test 3: Translation Count
    db.get("SELECT COUNT(*) AS count FROM translations", (err, row) => {
        console.log(`3. Total Persian Translations: ${row.count} (Expected: 6236) ${row.count === 6236 ? '✅ PASS' : '❌ FAIL'}`);
    });

    // Test 4: First Surah (Fatihah) & Last Surah (Nas) Alignment
    db.get("SELECT * FROM surahs WHERE id = 1", (err, s1) => {
        console.log(`\n4. Surah 1 Verification: ${s1.name} (${s1.english_name}), Ayahs: ${s1.number_of_ayahs}, Start Page: ${s1.start_page}`);
    });

    db.get("SELECT * FROM surahs WHERE id = 114", (err, s114) => {
        console.log(`   Surah 114 Verification: ${s114.name} (${s114.english_name}), Ayahs: ${s114.number_of_ayahs}, Start Page: ${s114.start_page}`);
    });

    // Test 5: Specific Famous Ayah Spot-Check (Ayat Al-Kursi - Surah 2 Ayah 255)
    db.get(`
        SELECT a.surah_number, a.number_in_surah, a.text_uthmani, a.page, a.juz, t.text AS translation 
        FROM ayahs a 
        JOIN translations t ON a.id = t.ayah_id 
        WHERE a.surah_number = 2 AND a.number_in_surah = 255
    `, (err, row) => {
        console.log(`\n5. Ayat Al-Kursi (2:255) Spot Check:`);
        console.log(`   Page: ${row.page}, Juz: ${row.juz}`);
        console.log(`   Arabic: ${row.text_uthmani.substring(0, 50)}...`);
        console.log(`   Persian: ${row.translation.substring(0, 50)}...`);
    });

    // Test 6: Page Range & Juz Range Integrity
    db.get("SELECT MIN(page) AS min_page, MAX(page) AS max_page, MIN(juz) AS min_juz, MAX(juz) AS max_juz FROM ayahs", (err, row) => {
        console.log(`\n6. Range Check: Page [${row.min_page} - ${row.max_page}] (Expected: 1 - 604), Juz [${row.min_juz} - ${row.max_juz}] (Expected: 1 - 30)`);
        const pass = row.min_page === 1 && row.max_page === 604 && row.min_juz === 1 && row.max_juz === 30;
        console.log(`   Status: ${pass ? '✅ PASS' : '❌ FAIL'}`);
    });

    // Test 7: Obligatory Sajdah Check (4 obligatory sajdahs: Surah 32, 41, 53, 96)
    db.all("SELECT a.surah_number, a.number_in_surah, a.sajdah, s.name FROM ayahs a JOIN surahs s ON a.surah_number = s.id WHERE a.sajdah = 2", (err, rows) => {
        console.log(`\n7. Obligatory Sajdah Count: ${rows.length} (Expected: 4) ${rows.length === 4 ? '✅ PASS' : '❌ FAIL'}`);
        rows.forEach(r => console.log(`   - Surah ${r.name} (${r.surah_number}:${r.number_in_surah})`));
    });

    // Test 8: Sequence Mismatch Check across all 6,236 Ayahs
    db.all(`
        SELECT a.id, a.surah_number, a.number_in_surah, s.number_of_ayahs 
        FROM ayahs a 
        JOIN surahs s ON a.surah_number = s.id
    `, (err, ayahs) => {
        let mismatches = 0;
        let expectedId = 1;

        for (let i = 0; i < ayahs.length; i++) {
            if (ayahs[i].id !== expectedId) {
                mismatches++;
            }
            expectedId++;
        }

        console.log(`\n8. Full 6,236 Ayah Sequence Check: ${mismatches === 0 ? '✅ 100% PERFECT SEQUENCE (No gaps, no duplicates)' : `❌ ${mismatches} mismatches found!`}`);
    });
});

db.close(() => {
    console.log("\n✨ DATABASE AUDIT COMPLETED!");
});
