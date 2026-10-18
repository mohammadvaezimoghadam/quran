#!/usr/bin/env python3
"""
Script to upload the newly built APK release to the OTA Server at /api/releases/upload
"""
import os
import sys
import time
import requests

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APK_PATH = os.path.join(PROJECT_DIR, 'build', 'app', 'outputs', 'flutter-apk', 'app-arm64-v8a-release.apk')

class ProgressFile:
    def __init__(self, filepath):
        self._f = open(filepath, 'rb')
        self._total = os.path.getsize(filepath)
        self._read = 0
        self._start = time.time()
        self._last_print = 0

    def read(self, size=-1):
        chunk = self._f.read(size)
        self._read += len(chunk)
        now = time.time()
        if now - self._last_print >= 3.0 or self._read == self._total:
            pct = (self._read / self._total) * 100 if self._total > 0 else 100
            elapsed = now - self._start
            speed = (self._read / 1024) / elapsed if elapsed > 0 else 0
            eta = (self._total - self._read) / (speed * 1024) if speed > 0 else 0
            print(f"   📊 [{pct:5.1f}%] {self._read/(1024*1024):.2f}/{self._total/(1024*1024):.2f} MB | {speed:.1f} KB/s | ETA: {int(eta)}s", flush=True)
            self._last_print = now
        return chunk

    def len(self):
        return self._total

    def close(self):
        self._f.close()


def upload_apk(server_url='http://5.22.203.61', apk_file=APK_PATH, version_name='1.0.1', version_code='2', notes='نسخه جدید ۱.۰.۱'):
    server_base = server_url.rstrip('/')
    url = f"{server_base}/api/releases/upload"

    if not os.path.exists(apk_file):
        print(f"❌ APK file not found at: {apk_file}")
        sys.exit(1)

    file_size_mb = os.path.getsize(apk_file) / (1024 * 1024)
    filename = os.path.basename(apk_file)

    print("═════════════════════════════════════════════════════════════════")
    print(f"🚀 [APK Upload] Deploying release APK to {url}")
    print(f"   File: {filename} ({file_size_mb:.2f} MB)")
    print(f"   Version Name: {version_name}")
    print(f"   Version Code: {version_code}")
    print(f"   Notes: {notes}")
    print("═════════════════════════════════════════════════════════════════")

    data = {
        'app_id': 'quran_tafakor',
        'version_name': version_name,
        'version_code': version_code,
        'is_force': '0',
        'activate': '1',
        'notes': notes,
        'filename': filename,
    }

    pf = ProgressFile(apk_file)
    session = requests.Session()
    session.trust_env = False

    # Bypass TUN adapters (VPNs/Proxies) by binding to physical network interface if available
    try:
        from requests.adapters import HTTPAdapter
        class SourceAddressAdapter(HTTPAdapter):
            def __init__(self, source_ip, *args, **kwargs):
                self.source_ip = source_ip
                super().__init__(*args, **kwargs)

            def init_poolmanager(self, *args, **kwargs):
                kwargs['source_address'] = (self.source_ip, 0)
                return super().init_poolmanager(*args, **kwargs)

        import socket
        # Detect physical Wi-Fi IP if active
        for probe_ip in ['10.254.65.253']:
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                s.bind((probe_ip, 0))
                s.close()
                session.mount("http://", SourceAddressAdapter(probe_ip))
                session.mount("https://", SourceAddressAdapter(probe_ip))
                print(f"   ⚡ Direct Route: Bound to physical interface {probe_ip} (Proxy Bypassed)")
                break
            except Exception:
                pass
    except Exception:
        pass

    try:
        start_t = time.time()
        resp = session.post(
            url,
            data=data,
            files={'file': (filename, pf, 'application/vnd.android.package-archive')},
            timeout=1200
        )
        elapsed = time.time() - start_t
        if resp.status_code in (200, 201):
            print(f"\n✅ [APK Upload] Success in {elapsed:.1f}s (HTTP {resp.status_code}):", flush=True)
            print(resp.json(), flush=True)
        else:
            print(f"\n⚠️ [APK Upload] Server returned {resp.status_code}:", flush=True)
            print(resp.text[:500], flush=True)
    except Exception as e:
        print(f"\n❌ [APK Upload] Error: {e}", flush=True)
    finally:
        pf.close()

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description="Upload APK Release to OTA Server")
    parser.add_argument('--server', default='http://5.22.203.61', help='OTA server base URL')
    parser.add_argument('--apk', default=APK_PATH, help='Path to release APK')
    parser.add_argument('--version', default='1.0.1', help='Version name (e.g. 1.0.1)')
    parser.add_argument('--code', default='2', help='Version code (e.g. 2)')
    parser.add_argument('--notes', default='نسخه جدید ۱.۰.۱ با اصلاحات و قابلیت‌های تازه', help='Release notes')
    args = parser.parse_args()

    upload_apk(
        server_url=args.server,
        apk_file=args.apk,
        version_name=args.version,
        version_code=args.code,
        notes=args.notes
    )
