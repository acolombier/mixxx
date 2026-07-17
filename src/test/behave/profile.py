"""DSL for setting up Mixxx test profiles and managing Mixxx process lifecycle."""

import json
import os
import shutil
import socket
import sqlite3
import subprocess
import sys
import tempfile
import threading
import time
import urllib.request
import xml.etree.ElementTree as ET

TRACK_MANIFEST = os.path.join(os.path.dirname(__file__), "test_tracks.json")
SETTINGS_FILE = "mixxx.cfg"
DATABASE_FILE = "mixxxdb.sqlite"
SCHEMA_FILE = os.path.join(
    os.path.dirname(__file__),
    os.pardir,
    os.pardir,
    os.pardir,
    "res",
    "schema.xml",
)


def profile_dir():
    return os.path.join(os.path.expanduser("~"), ".mixxx-test-profile")


def tracks_dir():
    return os.path.join(profile_dir(), "tracks")


def database_path():
    return os.path.join(profile_dir(), DATABASE_FILE)


def mixxx_cfg_path():
    return os.path.join(profile_dir(), SETTINGS_FILE)


def load_track_manifest():
    with open(TRACK_MANIFEST) as f:
        return json.load(f)


def _parse_schema(schema_path):
    tree = ET.parse(schema_path)
    root = tree.getroot()
    statements = []
    for revision in root.findall("revision"):
        sql_el = revision.find("sql")
        if sql_el is None or not sql_el.text or not sql_el.text.strip():
            continue
        statements.append(sql_el.text.strip())
    return statements


def _read_schema_version(schema_path):
    """Return (latest_version, min_compatible_version) from the schema XML."""
    tree = ET.parse(schema_path)
    root = tree.getroot()
    latest_version = 0
    min_compatible = 0
    for revision in root.findall("revision"):
        ver = int(revision.get("version", "0"))
        if ver > latest_version:
            latest_version = ver
            min_compatible = int(revision.get("min_compatible", "0"))
    return latest_version, min_compatible


def _database_has_tables(db_path):
    try:
        cur = sqlite3.connect(db_path).cursor()
        cur.execute("SELECT count(*) FROM sqlite_master WHERE type='table'")
        count = cur.fetchone()[0]
        cur.connection.close()
        return count > 0
    except Exception:
        return False


def _download_file(url, dest):
    req = urllib.request.Request(url, headers={"User-Agent": "MixxxTestProfile/1.0"})
    with urllib.request.urlopen(req, timeout=30) as response:
        with open(dest, "wb") as f:
            f.write(response.read())


def ensure_tracks_downloaded(target_dir=None):
    """Download all tracks from the manifest into target_dir (or default tracks_dir)."""
    if target_dir is None:
        target_dir = tracks_dir()
    os.makedirs(target_dir, exist_ok=True)
    manifest = load_track_manifest()
    downloaded = []
    for entry in manifest:
        filename = entry["filename"]
        url = entry.get("url")
        if not url:
            continue
        dest = os.path.join(target_dir, filename)
        if os.path.exists(dest) and os.path.getsize(dest) > 0:
            downloaded.append(dest)
            continue
        sys.stdout.write(f"Downloading {filename}...\n")
        sys.stdout.flush()
        try:
            _download_file(url, dest)
            downloaded.append(dest)
        except Exception as e:
            sys.stdout.write(f"  FAILED: {e}\n")
            sys.stdout.flush()
    return downloaded


def create_empty_profile(settings_dir=None):
    """Create a profile with schema-only database (no data rows)."""
    if settings_dir is None:
        settings_dir = profile_dir()
    os.makedirs(settings_dir, exist_ok=True)
    db_path = os.path.join(settings_dir, DATABASE_FILE)
    if os.path.exists(db_path) and _database_has_tables(db_path):
        return
    conn = sqlite3.connect(db_path)
    for sql in _parse_schema(SCHEMA_FILE):
        conn.executescript(sql)
    # Set schema version so SchemaManager doesn't re-apply migrations
    latest_ver, min_compat = _read_schema_version(SCHEMA_FILE)
    conn.execute(
        "INSERT OR REPLACE INTO settings (name, value) VALUES (?, ?)",
        ("mixxx.schema.version", str(latest_ver)),
    )
    conn.execute(
        "INSERT OR REPLACE INTO settings (name, value) VALUES (?, ?)",
        ("mixxx.schema.last_used_version", str(latest_ver)),
    )
    conn.execute(
        "INSERT OR REPLACE INTO settings (name, value) VALUES (?, ?)",
        ("mixxx.schema.min_compatible_version", str(min_compat)),
    )
    conn.commit()
    conn.close()
    cfg = os.path.join(settings_dir, SETTINGS_FILE)
    if not os.path.exists(cfg):
        with open(cfg, "w") as f:
            f.write("[Config]\n  Version = 2.6.0\n\n")
            f.write("[Library]\n  Show = 1\n\n")


def add_directory_to_db(track_dir, settings_dir=None):
    """Add a directory to the library's directory table."""
    if settings_dir is None:
        settings_dir = profile_dir()
    db_path = os.path.join(settings_dir, DATABASE_FILE)
    if not os.path.exists(db_path):
        return
    conn = sqlite3.connect(db_path)
    conn.execute(
        "INSERT OR IGNORE INTO directories (directory) VALUES (?)",
        (track_dir,),
    )
    conn.commit()
    conn.close()


_MIXXX_PROCESS = None


class MixxxProcess:
    """Manages a mixxx-test --serve subprocess for UI testing."""

    def __init__(self, binary, profile_dir, display=None):
        self.binary = binary
        self.profile_dir = profile_dir
        self.display = display
        self.process = None
        self.rpc = None

    def start(self, timeout=60):
        env = os.environ.copy()
        if self.display:
            env["DISPLAY"] = self.display

        args = [
            self.binary,
            "--serve",
            "--settings-path",
            self.profile_dir,
            "--developer",
            "--log-level",
            "debug",
        ]
        self.process = subprocess.Popen(
            args,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )

        def _pipe_logger():
            assert self.process is not None
            assert self.process.stdout is not None
            for line in self.process.stdout:
                sys.stdout.write(line)

        self._log_thread = threading.Thread(target=_pipe_logger, daemon=True)
        self._log_thread.start()

        deadline = time.time() + timeout
        while time.time() < deadline:
            try:
                s = socket.socket()
                s.settimeout(1)
                s.connect(("localhost", 9000))
                s.close()
                return
            except (OSError, ConnectionRefusedError):
                pass
            if self.process.poll() is not None:
                raise RuntimeError(
                    f"mixxx-test exited early with code {self.process.returncode}"
                )
            time.sleep(1)
        raise RuntimeError("Timed out waiting for Mixxx RPC on port 9000")

    def stop(self):
        if self.process is None:
            return
        self.process.terminate()
        try:
            self.process.wait(timeout=15)
        except subprocess.TimeoutExpired:
            self.process.kill()
            self.process.wait()
        self.process = None

    def __enter__(self):
        self.start()
        global _MIXXX_PROCESS
        _MIXXX_PROCESS = self
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        global _MIXXX_PROCESS
        _MIXXX_PROCESS = None
        self.stop()


def current_mixxx():
    """Return the active MixxxProcess (set by context manager or start)."""
    return _MIXXX_PROCESS


def setup_profile(base_dir, profile_type):
    """Create a profile of the given type in base_dir.

    Types:
      'empty'   - schema-only database, no tracks
      'basic'   - schema + directory entry pointing to MIXXX_TEST_TRACKS_DIR
    """
    create_empty_profile(base_dir)
    if profile_type == "basic":
        tracks = os.environ.get("MIXXX_TEST_TRACKS_DIR")
        if tracks:
            add_directory_to_db(tracks, base_dir)
    return base_dir


def make_temp_profile(profile_type="empty"):
    """Create a temporary profile directory and return its path."""
    base = tempfile.mkdtemp(prefix="mixxx-test-profile-")
    return setup_profile(base, profile_type)


def cleanup_profile(profile_dir):
    """Remove a profile directory created by make_temp_profile."""
    if profile_dir and os.path.exists(profile_dir):
        shutil.rmtree(profile_dir, ignore_errors=True)
