import requests
from bs4 import BeautifulSoup
import re
import subprocess
import os

# ===============================
# Settings
# ===============================
URL = "https://devcenter.unico.io/idcloud/integracao/sdk/integracao-sdks/sdk-flutter/release-notes"
DEPENDENCY = "unico_check"
REPO_PATH = "."  # Path to the local repository

# ===============================
# Step 1: Fetch version and release date from the website
# ===============================
response = requests.get(URL)
soup = BeautifulSoup(response.text, "html.parser")

spans = soup.find_all("span")
site_version = None
release_date = None

for span in spans:
    text_content = span.get_text(strip=True).replace("\u200b", "")  # remove zero-width space
    match = re.search(r"Versão\s*([\d.]+)\s*-\s*(\d{2}/\d{2}/\d{4})", text_content)
    if match:
        site_version = match.group(1)
        release_date = match.group(2)
        break

if not site_version:
    print("❌ Could not capture the version from the website")
    exit(0)

print(f"📦 Latest version on the website: {site_version}")
print(f"🗓️ Release date: {release_date}")

# ===============================
# Step 2: Read pubspec.yaml from the target repository
# ===============================

pubspec_path = os.path.join(REPO_PATH, "pubspec.yaml")
with open(pubspec_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

current_version = None
for line in lines:
    if line.strip().startswith(f"{DEPENDENCY}:"):
        current_version = line.strip().split(":")[1].strip()
        break

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
    subprocess.run(["git", "add", "package.json"], check=True)
    subprocess.run(["git", "commit", "-m", f"chore: bump {DEPENDENCY} to v{site_version}"], check=True)
    subprocess.run(["git", "push", "origin", branch], check=True)

    # Create git tag and push it
    subprocess.run(["git", "tag", "-a", tag, "-m", f"Release {DEPENDENCY} {site_version} ({release_date})"], check=True)
    subprocess.run(["git", "push", "origin", tag], check=True)

    # Create Pull Request using GitHub CLI
    body = f"""
    Automatic update of `{DEPENDENCY}` to version **{site_version}** 📅 Release date: **{release_date}** 🔗 [Official Release Notes]({URL})
    """

    # MODIFIED: Capture the output of the 'gh pr create' command
    pr_process = subprocess.run([
        "gh", "pr", "create",
        "--title", f"Update {DEPENDENCY} to v{site_version}",
        "--body", body,
        "--head", branch
    ], check=True, capture_output=True, text=True)

    # Extract the PR URL from stdout
    pr_url = pr_process.stdout.strip()
    print(f"✅ Pull Request created: {pr_url}")

    # Export output variables for GitHub Actions
    # This section writes the necessary data to a file so GitHub Actions can read them
    if "GITHUB_OUTPUT" in os.environ:
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            print(f"updated=true", file=f)
            print(f"new_version={site_version}", file=f)
            print(f"release_date={release_date}", file=f)
            print(f"pr_url={pr_url}", file=f)

else:
    print("🔄 Already at the latest version, nothing to do.")
    # If nothing was updated, set the 'updated' output to 'false'
    if "GITHUB_OUTPUT" in os.environ:
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            print(f"updated=false", file=f)