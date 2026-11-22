#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
=============================================================================
Quran Audio Synchronization Tool for ArvanCloud S3
=============================================================================
This tool downloads Quran recitation MP3 files from EveryAyah CDN and
uploads them directly to ArvanCloud S3 Object Storage with Public-Read ACL
and optimal HTTP caching headers (max-age=1 year).

Guarantees:
1. STRICT HALT: If ANY ayah fails to download or upload, the script
   immediately aborts so no ayah is ever skipped.
2. NO DUPLICATES: Checks existing S3 files beforehand; never re-downloads
   or re-uploads any file that already exists with valid size.
3. EXHAUSTIVE VERIFICATION: Automatically audits S3 after completion to
   verify that 100% of expected ayahs (1 to 114) exist and are non-empty.
=============================================================================
"""

import os
import sys
import time
import datetime
import argparse
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed

import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

# --- S3 Default Configuration ---
DEFAULT_ENDPOINT = "https://s3.ir-central1.arvanstorage.ir"
DEFAULT_BUCKET = "quran-tafakor-audio"
DEFAULT_ACCESS_KEY = os.environ.get("ARVAN_S3_ACCESS_KEY", "17305f14-40cb-4156-acc4-b441cc591f37")
DEFAULT_SECRET_KEY = os.environ.get("ARVAN_S3_SECRET_KEY", "5d6e63d88d39349e84d3c85e5af39e29c54f5cae72003a33b16d28b61f2a6ce1")
EVERYAYAH_BASE_URL = "https://www.everyayah.com/data"

# Quran Ayah Counts for all 114 Surahs (Total: 6,236 Ayahs)
SURAHS_AYAH_COUNTS = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109,
    123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
    112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
    34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
    54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
    28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
    29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
    15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
    11, 8, 3, 9, 5, 4, 7, 3, 6, 3,
    5, 4, 5, 6
]

# EXACT 47 ACTIVE RECITERS AND TRANSLATIONS IN THE APP (ZERO DUPLICATES)
ACTIVE_APP_RECITERS = [
    # --- Top Priority & Default Reciters ---
    (91, "شهریار پرهیزگار", "Parhizgar_48kbps", "48kbps"),
    (201, "ترجمه فولادوند (هدایت‌فر)", "translations/Fooladvand_Hedayatfar_40Kbps", "40kbps"),
    (202, "ترجمه مکارم شیرازی (کبیری)", "translations/Makarem_Kabiri_16Kbps", "16kbps"),
    (30, "استاد عبدالباسط (ترتیل)", "Abdul_Basit_Murattal_192kbps", "192kbps"),
    (76, "استاد محمد صدیق منشاوی (ترتیل)", "Minshawy_Murattal_128kbps", "128kbps"),
    (48, "استاد مشاری العفاسی", "Alafasy_128kbps", "128kbps"),
    (55, "استاد سعد الغامدی", "Ghamadi_40kbps", "40kbps"),
    (68, "کریم منصوری", "Karim_Mansoori_40kbps", "40kbps"),
    (70, "استاد ماهر المعیقلی", "MaherAlMuaiqly128kbps", "128kbps"),
    (61, "استاد محمود خلیل الحصری", "Husary_128kbps", "128kbps"),

    # --- Other Active Arabic Reciters in App ---
    (34, "استاد عبدالله الجهنی", "Abdullaah_3awwaad_Al-Juhaynee_128kbps", "128kbps"),
    (35, "استاد عبدالله بصفر", "Abdullah_Basfar_192kbps", "192kbps"),
    (38, "استاد عبدالله مطرود", "Abdullah_Matroud_128kbps", "128kbps"),
    (39, "استاد عبدالرحمن السدیس", "Abdurrahmaan_As-Sudais_192kbps", "192kbps"),
    (42, "استاد ابو بکر الشاطری", "Abu_Bakr_Ash-Shaatree_128kbps", "128kbps"),
    (44, "احمد نعینع", "Ahmed_Neana_128kbps", "128kbps"),
    (45, "استاد احمد بن علی العجمی", "Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net", "128kbps"),
    (47, "اکرم العلاقمی", "Akram_AlAlaqimy_128kbps", "128kbps"),
    (50, "علی حجاج السویسی", "Ali_Hajjaj_AlSuesy_128kbps", "128kbps"),
    (51, "علی جابر", "Ali_Jaber_64kbps", "64kbps"),
    (52, "ایمن سوید", "Ayman_Sowaid_64kbps", "64kbps"),
    (54, "فارس عباد", "Fares_Abbad_64kbps", "64kbps"),
    (56, "استاد هانی الرفاعی", "Hani_Rifai_192kbps", "192kbps"),
    (58, "استاد علی بن عبدالرحمن الحذیفی", "Hudhaify_128kbps", "128kbps"),
    (66, "استاد ابراهیم الاخضر", "Ibrahim_Akhdar_32kbps", "32kbps"),
    (69, "خالد القحطانی", "Khaalid_Abdullaah_al-Qahtaanee_192kbps", "192kbps"),
    (78, "استاد محمد الطبلاوی", "Mohammad_al_Tablaway_128kbps", "128kbps"),
    (80, "محمد عبدالکریم", "Muhammad_AbdulKareem_128kbps", "128kbps"),
    (81, "استاد محمد ایوب", "Muhammad_Ayyoub_128kbps", "128kbps"),
    (84, "استاد محمد جبریل", "Muhammad_Jibreel_128kbps", "128kbps"),
    (86, "محسن القاسم", "Muhsin_Al_Qasim_192kbps", "192kbps"),
    # Disabled: source EveryAyah archive lacks Surahs 3-45 (4,220 ayahs missing)
    # (88, "مصطفی اسماعیل", "Mustafa_Ismail_48kbps", "48kbps"),
    (89, "نبیل الرفاعی", "Nabil_Rifa3i_48kbps", "48kbps"),
    (90, "ناصر القطامی", "Nasser_Alqatami_128kbps", "128kbps"),
    (94, "سهل یاسین", "Sahl_Yassin_128kbps", "128kbps"),
    (95, "صلاح بوخاطر", "Salaah_AbdulRahman_Bukhatir_128kbps", "128kbps"),
    (96, "صلاح البدیر", "Salah_Al_Budair_128kbps", "128kbps"),
    (98, "استاد سعود الشریم", "Saood_ash-Shuraym_128kbps", "128kbps"),
    (101, "یاسر سلامه", "Yaser_Salamah_128kbps", "128kbps"),
    (102, "یاسر الدوسری", "Yasser_Ad-Dussary_128kbps", "128kbps"),
    (104, "عزیز علیلی", "aziz_alili_128kbps", "128kbps"),
    (106, "خلیفه التناجی", "khalefa_al_tunaiji_64kbps", "64kbps"),
    (107, "محمود علی البنا", "mahmoud_ali_al_banna_32kbps", "32kbps"),

    # --- Translations in App ---
    (203, "ترجمه انگلیسی (ابراهیم واک)", "English/Sahih_Intnl_Ibrahim_Walk_192kbps", "192kbps"),
    (204, "ترجمه بوسنیایی (بسیم کورکوت)", "translations/besim_korkut_ajet_po_ajet", "64kbps"),
    (205, "ترجمه اردو (فرهت هاشمی)", "translations/urdu_farhat_hashmi", "64kbps"),
    (206, "ترجمه اردو (شمشاد علی خان)", "translations/urdu_shamshad_ali_khan_46kbps", "46kbps"),
]

POPULAR_RECITERS = ACTIVE_APP_RECITERS[:10]


def create_s3_client(endpoint, access_key, secret_key):
    return boto3.client(
        "s3",
        endpoint_url=endpoint,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        config=Config(
            signature_version="s3v4",
            max_pool_connections=25,
            retries={"max_attempts": 5, "mode": "standard"},
        ),
    )


def get_existing_s3_keys(s3, bucket, prefix):
    """Retrieve all existing keys for a prefix from S3 into a set for O(1) existence checks."""
    print(f"  🔍 Checking existing files in S3 for '{prefix}'...")
    existing = set()
    paginator = s3.get_paginator("list_objects_v2")
    try:
        for page in paginator.paginate(Bucket=bucket, Prefix=f"{prefix}/"):
            for obj in page.get("Contents", []):
                # Ensure object is non-empty and valid audio (at least 512 bytes)
                if obj.get("Size", 0) > 512:
                    existing.add(obj["Key"])
    except Exception as e:
        print(f"  ⚠️ Warning when listing S3 objects: {e}")
    print(f"  ✓ Found {len(existing):,} valid files already uploaded.")
    return existing


def transfer_single_ayah(subfolder, surah, ayah, s3, bucket):
    """Downloads one ayah MP3 from EveryAyah and uploads it to S3."""
    file_name = f"{surah:03d}{ayah:03d}.mp3"
    s3_key = f"{subfolder}/{file_name}"
    source_url = f"{EVERYAYAH_BASE_URL}/{subfolder}/{file_name}"

    # Download from EveryAyah with retries (up to 5 attempts)
    data = None
    last_err = None
    for attempt in range(1, 6):
        try:
            req = urllib.request.Request(
                source_url,
                headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) QuranTafakor/1.0"}
            )
            with urllib.request.urlopen(req, timeout=30) as resp:
                if resp.status == 200:
                    data = resp.read()
                    # Validate MP3 payload: must not be empty or HTML error page
                    if len(data) < 512 or data.startswith(b"<!DOCTYPE") or data.startswith(b"<html"):
                        last_err = f"Invalid content received (size: {len(data)})"
                        data = None
                        time.sleep(1.2 * attempt)
                        continue
                    break
                else:
                    last_err = f"HTTP status {resp.status}"
        except Exception as e:
            last_err = str(e)
            time.sleep(1.2 * attempt)

    if not data or len(data) == 0:
        return False, s3_key, 0, f"Download failed after 5 attempts: {source_url} (Error: {last_err})"

    # Upload to S3 with retries (up to 5 attempts)
    upload_err = None
    for attempt in range(1, 6):
        try:
            s3.put_object(
                Bucket=bucket,
                Key=s3_key,
                Body=data,
                ContentType="audio/mpeg",
                ACL="public-read",
                CacheControl="public, max-age=31536000, immutable",
            )
            return True, s3_key, len(data), None
        except Exception as e:
            upload_err = str(e)
            time.sleep(1.2 * attempt)

    return False, s3_key, 0, f"S3 upload failed after 5 attempts: {upload_err}"


def verify_reciter(reciter_name, subfolder, s3, bucket, surah_filter=None):
    """
    Exhaustively audits S3 to guarantee that 100% of the expected ayahs exist
    and are valid non-zero byte MP3 files.
    """
    print(f"\n  🔎 [VERIFICATION] Auditing S3 for {reciter_name} ({subfolder})...")

    paginator = s3.get_paginator("list_objects_v2")
    s3_objects = {}  # key -> size
    try:
        for page in paginator.paginate(Bucket=bucket, Prefix=f"{subfolder}/"):
            for obj in page.get("Contents", []):
                s3_objects[obj["Key"]] = obj.get("Size", 0)
    except Exception as e:
        print(f"  ❌ Error reading S3 objects during verification: {e}")
        return False

    surahs_to_check = [surah_filter] if surah_filter else range(1, 115)
    missing_ayahs = []
    zero_byte_ayahs = []
    total_expected = 0

    for surah in surahs_to_check:
        if surah < 1 or surah > 114:
            continue
        ayah_count = SURAHS_AYAH_COUNTS[surah - 1]
        for ayah in range(1, ayah_count + 1):
            total_expected += 1
            key = f"{subfolder}/{surah:03d}{ayah:03d}.mp3"
            if key not in s3_objects:
                missing_ayahs.append(key)
            elif s3_objects[key] <= 0:
                zero_byte_ayahs.append(key)

    print(f"  📊 Total expected files: {total_expected:,}")
    print(f"  📊 Found in S3: {len(s3_objects):,}")

    if missing_ayahs:
        print(f"\n  ❌ VERIFICATION FAILED! {len(missing_ayahs)} Ayahs are MISSING in S3:")
        for m in missing_ayahs[:15]:
            print(f"     - Missing: {m}")
        if len(missing_ayahs) > 15:
            print(f"     ... and {len(missing_ayahs) - 15} more.")
        return False

    if zero_byte_ayahs:
        print(f"\n  ❌ VERIFICATION FAILED! {len(zero_byte_ayahs)} Ayahs are corrupted (0 bytes):")
        for z in zero_byte_ayahs[:15]:
            print(f"     - Corrupted: {z}")
        return False

    total_mb = sum(s3_objects.values()) / (1024 * 1024)
    print(f"  ✅ [100% VERIFIED] All {total_expected:,} Ayahs exist on S3 perfectly!")
    print(f"  ✅ Total Size: {total_mb:.1f} MB ({total_mb / 1024:.2f} GB)")
    print(f"  ✅ Zero missing files, zero corrupted files, zero duplicate uploads.\n")
    return True


def sync_reciter(reciter_name, subfolder, s3, bucket, workers=10, surah_filter=None):
    print(f"\n=======================================================")
    print(f"🎵 Syncing: {reciter_name} ({subfolder})")
    print(f"=======================================================")

    # 1. Fetch existing keys from S3
    existing_keys = get_existing_s3_keys(s3, bucket, subfolder)

    # 2. Build list of pending tasks
    pending_tasks = []
    surahs_to_process = [surah_filter] if surah_filter else range(1, 115)

    for surah in surahs_to_process:
        if surah < 1 or surah > 114:
            continue
        ayah_count = SURAHS_AYAH_COUNTS[surah - 1]
        for ayah in range(1, ayah_count + 1):
            key = f"{subfolder}/{surah:03d}{ayah:03d}.mp3"
            if key not in existing_keys:
                pending_tasks.append((subfolder, surah, ayah))

    total_ayahs = sum(SURAHS_AYAH_COUNTS[s - 1] for s in surahs_to_process)
    print(f"  📊 Total Ayahs: {total_ayahs:,} | Already on S3: {len(existing_keys):,} | Pending to upload: {len(pending_tasks):,}")

    if not pending_tasks:
        print(f"  ✨ All files for {reciter_name} are already on S3!")
        verify_reciter(reciter_name, subfolder, s3, bucket, surah_filter=surah_filter)
        return

    # 3. Multi-threaded processing with STRICT ABORT on any error
    transferred_bytes = 0
    success_count = 0
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {
            executor.submit(transfer_single_ayah, item[0], item[1], item[2], s3, bucket): item
            for item in pending_tasks
        }

        for idx, future in enumerate(as_completed(futures), 1):
            success, key, byte_len, err = future.result()

            if not success:
                # STRICT STOP: Cancel all remaining tasks immediately and halt
                executor.shutdown(wait=False, cancel_futures=True)
                print(f"\n\n=======================================================")
                print(f"⛔ CRITICAL ERROR: SCRIPT STOPPED IMMEDIATELY!")
                print(f"Ayah failed: {key}")
                print(f"Error detail: {err}")
                print(f"Stopped so no ayah is skipped or left behind.")
                print(f"=======================================================\n")
                sys.exit(1)

            success_count += 1
            transferred_bytes += byte_len

            # Progress indicator
            if idx % 50 == 0 or idx == len(pending_tasks):
                elapsed = max(0.1, time.time() - start_time)
                speed_mbps = (transferred_bytes / (1024 * 1024)) / elapsed
                mb_transferred = transferred_bytes / (1024 * 1024)
                pct = (idx / len(pending_tasks)) * 100
                status_str = (
                    f"🚀 Progress: {idx}/{len(pending_tasks)} ({pct:.1f}%) | "
                    f"Uploaded: {mb_transferred:.1f} MB ({speed_mbps:.2f} MB/s) | "
                    f"Success: {success_count}"
                )
                if sys.stdout.isatty():
                    sys.stdout.write(f"\r  {status_str}   ")
                    sys.stdout.flush()
                else:
                    now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    print(f"[{now_str}] {status_str}", flush=True)

    total_time = time.time() - start_time
    print(f"\n  ✅ Upload completed in {total_time:.1f}s ({success_count} uploaded).")

    # 4. Automatic exhaustive audit after sync
    is_valid = verify_reciter(reciter_name, subfolder, s3, bucket, surah_filter=surah_filter)
    if not is_valid:
        print("⛔ Post-sync audit failed! Exiting with error.")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Sync Quran audio from EveryAyah to ArvanCloud S3")
    parser.add_argument("--reciter", type=str, help="Subfolder of specific reciter (e.g. Parhizgar_48kbps)")
    parser.add_argument("--popular", action="store_true", help="Sync top 10 most popular reciters")
    parser.add_argument("--all", action="store_true", help="Sync all 47 active reciters in the app")
    parser.add_argument("--start-index", type=int, default=1, help="1-based start index for --all (default: 1)")
    parser.add_argument("--surah", type=int, help="Sync specific Surah number (1-114) for quick testing")
    parser.add_argument("--verify", action="store_true", help="Verify S3 files for a reciter without uploading")
    parser.add_argument("--workers", type=int, default=10, help="Number of parallel upload workers (default: 10)")
    parser.add_argument("--bucket", type=str, default=DEFAULT_BUCKET, help=f"S3 Bucket name (default: {DEFAULT_BUCKET})")
    parser.add_argument("--endpoint", type=str, default=DEFAULT_ENDPOINT, help=f"S3 Endpoint (default: {DEFAULT_ENDPOINT})")
    parser.add_argument("--access-key", type=str, default=DEFAULT_ACCESS_KEY, help="ArvanCloud S3 Access Key")
    parser.add_argument("--secret-key", type=str, default=DEFAULT_SECRET_KEY, help="ArvanCloud S3 Secret Key")
    parser.add_argument("--list", action="store_true", help="List all 47 active reciters in the app")

    args = parser.parse_args()

    if args.list:
        print("List of active reciters in Quran Tafakor app (Total: 47):")
        for idx, (r_id, name, sub, br) in enumerate(ACTIVE_APP_RECITERS, 1):
            print(f"  {idx:2d}. [ID {r_id:3d}] {name:<35} | {br:<8} | {sub}")
        return

    print("=======================================================")
    print("✨ Quran Audio S3 Uploader (ArvanCloud)")
    print(f"Bucket: {args.bucket}")
    print(f"Endpoint: {args.endpoint}")
    print("=======================================================")

    s3 = create_s3_client(args.endpoint, args.access_key, args.secret_key)

    if args.verify:
        target = args.reciter or "Parhizgar_48kbps"
        matched = [(n, s) for _, n, s, _ in ACTIVE_APP_RECITERS if s.lower() == target.lower() or target.lower() in s.lower()]
        name, sub = matched[0] if matched else (target, target)
        verify_reciter(name, sub, s3, args.bucket, surah_filter=args.surah)
        return

    if args.reciter:
        matched = [(n, s) for _, n, s, _ in ACTIVE_APP_RECITERS if s.lower() == args.reciter.lower() or args.reciter.lower() in s.lower()]
        if not matched:
            matched = [(args.reciter, args.reciter)]
        for name, sub in matched:
            sync_reciter(name, sub, s3, args.bucket, workers=args.workers, surah_filter=args.surah)
    elif args.popular:
        for _, name, sub, _ in POPULAR_RECITERS:
            sync_reciter(name, sub, s3, args.bucket, workers=args.workers, surah_filter=args.surah)
    elif args.all:
        start_idx = max(1, args.start_index) - 1
        for _, name, sub, _ in ACTIVE_APP_RECITERS[start_idx:]:
            sync_reciter(name, sub, s3, args.bucket, workers=args.workers, surah_filter=args.surah)
    else:
        # Default: sync default free reciter (Parhizgar)
        print("No specific option chosen. Defaulting to free reciter (Parhizgar_48kbps).")
        print("Use --help to see all options (e.g. --popular, --all, --surah).")
        sync_reciter("شهریار پرهیزگار", "Parhizgar_48kbps", s3, args.bucket, workers=args.workers, surah_filter=args.surah)


if __name__ == "__main__":
    main()
