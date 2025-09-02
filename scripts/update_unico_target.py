import requests
from bs4 import BeautifulSoup
import re
import subprocess
import os
import yaml

# ===============================
# Settings
# ===============================
URL = "https://devcenter.unico.io/idcloud/integracao/sdk/integracao-sdks/sdk-android/release-notes"
DEPENDENCY = "unico_check"
REPO_PATH = "."  # Path to the local repository
PUBSPEC_PATH = os.path.join(REPO_PATH, "pubspec.yaml")

# ===============================
# 1️⃣ Fetch version + date from the website
# ===============================
response = requests.get(URL)
soup = BeautifulSoup(response.text, "html.parser")
div = soup.find("div", class_="flex-1 z-1 max-w-full break-words text-start justify-self-start leading-snug")

site_version = None
release_date = None

if div:
    text_content = div.get_text(strip=True)
    match = re.search(r"Versão\s+([\d.]+)\s*-\s*(\d{2}/\d{2}/\d{4})", text_content)
    if match:
        site_version = match.group(1)
        release_date = match.group(2)

if not site_version:
    print("❌ Could not capture the version from the website")
    exit(0)

print(f"📦 Latest version on the website: {site_version}")
print(f"🗓️ Release date: {release_date}")

# ===============================
# 2️⃣ Read pubspec.yaml
# ===============================
with open(PUBSPEC_PATH, "r", encoding="utf-8") as f:
    pubspec = yaml.safe_load(f)

current_version = pubspec.get("dependencies", {}).get(DEPENDENCY)
print(f"📂 Current version in pubspec.yaml: {current_version}")

# ===============================
# 3️⃣ Update if necessary
# ===============================
if current_version != site_version:
    pubspec["dependencies"][DEPENDENCY] = site_version
    with open(PUBSPEC_PATH, "w", encoding="utf-8") as f:
        yaml.dump(pubspec, f, sort_keys=False, allow_unicode=True)

    print(f"✅ Updated {DEPENDENCY} to version {site_version}")

    branch = f"update-{DEPENDENCY}-v{site_version}"
    tag = f"{DEPENDENCY}-v{site_version}"

    subprocess.run(["git", "checkout", "-b", branch], check=True)
    subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
    subprocess.run(["git", "config", "user.email", "github-actions@github.com"], check=True)
    subprocess.run(["git", "add", "pubspec.yaml"], check=True)
    subprocess.run(["git", "commit", "-m", f"chore: bump {DEPENDENCY} to v{site_version}"], check=True)
    subprocess.run(["git", "push", "origin", branch], check=True)

    subprocess.run(["git", "tag", "-a", tag, "-m", f"Release {DEPENDENCY} {site_version} ({release_date})"], check=True)
    subprocess.run(["git", "push", "origin", tag], check=True)

    body = f"""
    Automatic update of `{DEPENDENCY}` to version **{site_version}** 📅 Release date: **{release_date}** 🔗 [Official Release Notes]({URL})
    """

    subprocess.run([
        "gh", "pr", "create",
        "--title", f"Update {DEPENDENCY} to v{site_version}",
        "--body", body,
        "--head", branch
    ], check=True)

else:
    print("🔄 Already at the latest version, nothing to do.")
