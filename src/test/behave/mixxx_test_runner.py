#!/usr/bin/env python3
"""CTest entry point for the Mixxx behave UI tests.

Usage: mixxx_test_runner.py [options] [feature_file...]

Sets up a global tracks cache, optional headless display, then runs behave.
Profile setup and mixxx-test lifecycle are handled by the behave steps.
"""

import os
import shutil
import subprocess
import sys
import tempfile
import time
import argparse


def main():
    this_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, this_dir)

    import profile

    parser = argparse.ArgumentParser(description="Mixxx UI test runner")
    parser.add_argument(
        "--headless",
        type=int,
        default=int(os.environ.get("MIXXX_TEST_HEADLESS", "0")),
        choices=[0, 1],
        help="Run in headless mode with Xvfb + ffmpeg recording",
    )
    parser.add_argument(
        "--binary",
        default=os.environ.get("MIXXX_TEST_BINARY", "mixxx-test"),
        help="Path to the mixxx-test binary",
    )
    parser.add_argument(
        "behave_args",
        nargs="*",
        help="Arguments forwarded to behave (e.g. feature file paths)",
    )

    args = parser.parse_args()

    os.environ["MIXXX_TEST_BINARY"] = args.binary
    os.environ["MIXXX_TEST_BEHAVE_DIR"] = this_dir

    # Set up global tracks cache (shared across all feature tests)
    tracks_cache = os.environ.get("MIXXX_TEST_TRACKS_DIR")
    if not tracks_cache:
        tracks_cache = os.path.join(tempfile.gettempdir(), "mixxx-test-tracks")
    os.makedirs(tracks_cache, exist_ok=True)
    os.environ["MIXXX_TEST_TRACKS_DIR"] = tracks_cache

    # Download tracks if not already cached
    profile.ensure_tracks_downloaded(tracks_cache)

    ffmpeg_proc = None
    xvfb_proc = None

    if args.headless:
        if shutil.which("Xvfb") and shutil.which("ffmpeg"):
            display_num = os.environ.get("MIXXX_TEST_DISPLAY", ":44")
            os.environ["DISPLAY"] = display_num
            os.environ["QT_QPA_PLATFORM"] = "xcb"

            artifacts = os.path.join(this_dir, "artifacts")
            os.makedirs(artifacts, exist_ok=True)
            video = os.environ.get("MIXXX_TEST_VIDEO", "output.mkv")

            xvfb_proc = subprocess.Popen(
                [
                    "Xvfb",
                    display_num,
                    "-ac",
                    "-nocursor",
                    "-screen",
                    "0",
                    "1920x1080x24",
                    "-auth",
                    "/dev/null",
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            time.sleep(3)

            ffmpeg_proc = subprocess.Popen(
                [
                    "ffmpeg",
                    "-nostdin",
                    "-hide_banner",
                    "-loglevel",
                    "error",
                    "-f",
                    "x11grab",
                    "-video_size",
                    "1920x1080",
                    "-i",
                    display_num,
                    "-draw_mouse",
                    "0",
                    "-codec:v",
                    "mpeg4",
                    "-r",
                    "30",
                    "-b:v",
                    "2000k",
                    os.path.join(artifacts, video),
                    "-y",
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        else:
            print("Xvfb/ffmpeg not found - using offscreen platform")
            os.environ["QT_QPA_PLATFORM"] = "offscreen"

    exit_code = 1
    try:
        behave_argv = [sys.executable, "-m", "behave"] + args.behave_args
        result = subprocess.run(
            behave_argv,
            env=os.environ,
            cwd=this_dir,
        )
        exit_code = result.returncode
    finally:
        if ffmpeg_proc:
            ffmpeg_proc.terminate()
            ffmpeg_proc.wait()
        if xvfb_proc:
            xvfb_proc.terminate()
            xvfb_proc.wait()

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
