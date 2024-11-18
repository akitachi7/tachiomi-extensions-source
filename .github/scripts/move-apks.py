import argparse
import os
import re
import shutil
import subprocess
from pathlib import Path

IS_NSFW_REGEX = re.compile(r"'tachiyomi.extension.nsfw' value='([^']+)'")

*_, ANDROID_BUILD_TOOLS = (Path(os.environ["ANDROID_HOME"]) / "build-tools").iterdir()

# Modify REPO_DIR based on command-line argument
def move_apks(repo_dir, nsfw_filter):
    REPO_DIR = Path(repo_dir)
    REPO_APK_DIR = REPO_DIR / "apk"

    try:
        shutil.rmtree(REPO_APK_DIR)
    except FileNotFoundError:
        pass

    REPO_APK_DIR.mkdir(parents=True, exist_ok=True)

    for apk in (Path.home() / "apk-artifacts").glob("**/*.apk"):
        apk_name = apk.name.replace("-release.apk", ".apk")
        badging = subprocess.check_output(
            [
                ANDROID_BUILD_TOOLS / "aapt",
                "dump",
                "--include-meta-data",
                "badging",
                apk,
            ]
        ).decode()
        nsfw = int(IS_NSFW_REGEX.search(badging).group(1))

        # Move the APK based on the NSFW filter
        if nsfw_filter is None or nsfw == nsfw_filter:
            shutil.move(apk, REPO_APK_DIR / apk_name)
            print(f"Moved: {apk_name}")


# Parse command line arguments to accept --dir flag
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Move APKs into the repository")
    parser.add_argument("--dir", type=str, required=True, help="Directory for the repo")
    parser.add_argument(
        "--nsfw", type=int, choices=[0, 1], help="Filter APKs based on NSFW status (0 or 1)"
    )
    args = parser.parse_args()

    # Call the function with the provided directory and NSFW filter
    move_apks(args.dir, args.nsfw)