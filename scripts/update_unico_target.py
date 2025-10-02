import requests
import re
from bs4 import BeautifulSoup
import subprocess
import os

# ===============================
# Constants
# ===============================
URL = "https://pub.dev/packages/unico_check/changelog"
DEPENDENCY = "unico_check"
REPO_PATH = "."

# ===============================
# Step 1: Fetch and parse the website
# ===============================
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}
response = requests.get(URL, headers=headers)
response.raise_for_status()

soup = BeautifulSoup(response.text, "html.parser")

site_version = None
release_date = None
release_notes = []

# ===============================
# Step 2: Extract information based on the pub.dev structure
# ===============================
latest_version_header = soup.find("h2", class_="changelog-version")

if latest_version_header:
    site_version = latest_version_header.get_text(strip=True).split()[0]
    content_div = latest_version_header.find_next_sibling("div", class_="changelog-content")

    if content_div:
        date_paragraph = content_div.find("p", string=re.compile(r"Publicado:"))
        if date_paragraph:
            match_date = re.search(r"(\d{2}/\d{2}/\d{4})", date_paragraph.get_text())
            if match_date:
                release_date = match_date.group(1)

        notes_elements = content_div.find_all(['li', 'p'])
        for element in notes_elements:
            note_text = element.get_text(strip=True)
            if "Publicado:" not in note_text and note_text:
                release_notes.append(note_text)

if not site_version:
    print("❌ Could not capture the version from the website")
    exit(0)

print(f"📦 Latest version on the website: {site_version}")
print(f"🗓️ Release date: {release_date}")

# --- BLOCO CORRIGIDO E REINSERIDO ---
if release_notes:
    print("\n📝 Release notes found:")
    for note in release_notes:
        print(f"- {note}")
else:
    print("⚠️ No release notes were found.")
# --- FIM DA CORREÇÃO ---

# ===============================
# Step 2.5: Read pubspec.yaml from the target repository
# ===============================
pubspec_path = os.path.join(REPO_PATH, "pubspec.yaml")
try:
    with open(pubspec_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
except FileNotFoundError:
    print(f"❌ Error: pubspec.yaml not found at {pubspec_path}")
    exit(1)

current_version = None
for line in lines:
    if line.strip().startswith(f"{DEPENDENCY}:"):
        current_version = line.strip().split(":")[1].strip()
        break

if current_version is None:
    print(f"❌ Error: Dependency '{DEPENDENCY}' not found in {pubspec_path}")
    exit(1)

print(f"📂 Current version in pubspec.yaml: {current_version}")

# ===============================
# Step 3: Update dependency if necessary
# ===============================
if current_version != site_version:
    new_lines = []
    for line in lines:
        if line.strip().startswith(f"{DEPENDENCY}:"):
            new_lines.append(f"  {DEPENDENCY}: {site_version}\n")
        else:
            new_lines.append(line)

    with open(pubspec_path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print(f"✅ Updated {DEPENDENCY} to version {site_version}")

    branch = f"update-{DEPENDENCY}-v{site_version}"
    tag = f"{DEPENDENCY}-v{site_version}"

    # Create branch, commit, and push changes
    subprocess.run(["git", "checkout", "-b", branch], check=True)
    subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
    subprocess.run(["git", "config", "user.email", "github-actions@github.com"], check=True)
    subprocess.run(["git", "add", "pubspec.yaml"], check=True)
    subprocess.run(["git", "commit", "-m", f"chore: bump {DEPENDENCY} to v{site_version}"], check=True)
    subprocess.run(["git", "push", "origin", branch], check=True)

    # Create git tag and push it
    subprocess.run(["git", "tag", "-a", tag, "-m", f"Release {DEPENDENCY} {site_version} ({release_date})"], check=True)
    subprocess.run(["git", "push", "origin", tag], check=True)

    # Create Pull Request using GitHub CLI
    formatted_notes = "\n".join([f"- {note}" for note in release_notes])
    body = f"""
    Automatic update of `{DEPENDENCY}` to version **{site_version}**.
    
    📅 **Release date:** {release_date}
    🔗 **Changelog:** {URL}

    ---
    
    ### Release Notes
    {formatted_notes}
    """

    # Capture the output of the 'gh pr create' command
    pr_process = subprocess.run([
        "gh", "pr", "create",
        "--title", f"Update {DEPENDENCY} to v{site_version}",
        "--body", body,
        "--head", branch
    ], check=True, capture_output=True, text=True)

    pr_url = pr_process.stdout.strip()
    print(f"✅ Pull Request created: {pr_url}")

    # Export output variables for GitHub Actions
    if "GITHUB_OUTPUT" in os.environ:
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            print(f"updated=true", file=f)
            print(f"new_version={site_version}", file=f)
            print(f"release_date={release_date}", file=f)
            print(f"pr_url={pr_url}", file=f)

else:
    print("🔄 Already at the latest version, nothing to do.")
    if "GITHUB_OUTPUT" in os.environ:
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            print(f"updated=false", file=f)