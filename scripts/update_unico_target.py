import requests
import re
import subprocess
import os
import yaml

# ===============================
# Settings
# ===============================
# URL foi alterada para o endpoint da API que fornece o conteúdo dinâmico
# Esta URL é para o SDK do Android, conforme o link que você enviou.
URL = "https://devcenter.unico.io/api/v1/projects/e8f74033-5c3b-45e0-827c-3f9f30b207ef/docs/integracao-sdks/sdk-android/release-notes"

# O nome da dependência no seu código original era "unico_check" (Flutter)
# Ajuste o nome da dependência conforme necessário para o seu projeto.
DEPENDENCY = "unico_check"
REPO_PATH = "."  # Caminho para o repositório local
PUBSPEC_PATH = os.path.join(REPO_PATH, "pubspec.yaml")

# ===============================
# 1️⃣ Fetch version + date from the website's API
# ===============================
print(f"📡 Fetching data from: {URL}")

headers = {
    'Accept': 'application/json', # Informa ao servidor que esperamos uma resposta JSON
}

try:
    response = requests.get(URL, headers=headers, timeout=15)
    # Lança um erro para respostas HTTP mal-sucedidas (ex: 404, 500)
    response.raise_for_status()
except requests.exceptions.RequestException as e:
    print(f"❌ Failed to fetch data from the API: {e}")
    exit(1)


# Decodifica a resposta JSON e extrai o conteúdo de texto do campo 'body'
json_data = response.json()
text_content = json_data.get('body', '')

site_version = None
release_date = None

if text_content:
    # A regex original funciona perfeitamente com o texto extraído do JSON
    match = re.search(r"Versão\s+([\d.]+)\s*-\s*(\d{2}/\d{2}/\d{4})", text_content)
    if match:
        site_version = match.group(1)
        release_date = match.group(2)

if not site_version:
    print("❌ Could not capture the version from the website's API response.")
    exit(0)

print(f"📦 Latest version on the website: {site_version}")
print(f"🗓️ Release date: {release_date}")

# ===============================
# 2️⃣ Read pubspec.yaml
# ===============================
if not os.path.exists(PUBSPEC_PATH):
    print(f"❌ Error: pubspec.yaml not found at the path '{PUBSPEC_PATH}'")
    exit(1)

try:
    with open(PUBSPEC_PATH, "r", encoding="utf-8") as f:
        pubspec = yaml.safe_load(f)
except yaml.YAMLError as e:
    print(f"❌ Error parsing pubspec.yaml: {e}")
    exit(1)


current_version = pubspec.get("dependencies", {}).get(DEPENDENCY)
print(f"📂 Current version in pubspec.yaml: {current_version or 'Not found'}")

# ===============================
# 3️⃣ Update if necessary
# ===============================
# Compara a versão do site com a versão atual, tratando o caso de a versão no pubspec ter um prefixo como '^'
if current_version is None or site_version not in current_version:
    new_version_string = f"^{site_version}" if current_version and current_version.startswith('^') else site_version
    
    pubspec["dependencies"][DEPENDENCY] = new_version_string
    
    with open(PUBSPEC_PATH, "w", encoding="utf-8") as f:
        # Escreve de volta no arquivo YAML preservando a formatação o máximo possível
        yaml.dump(pubspec, f, sort_keys=False, allow_unicode=True, default_flow_style=False, indent=2)

    print(f"✅ Updated {DEPENDENCY} to version {new_version_string} in pubspec.yaml")

    # --- Bloco para automação com Git e GitHub CLI (gh) ---
    branch = f"update-{DEPENDENCY}-v{site_version}"
    tag = f"{DEPENDENCY}-v{site_version}"

    print("🚀 Starting git operations...")
    try:
        subprocess.run(["git", "checkout", "-b", branch], check=True, capture_output=True, text=True)
        subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
        subprocess.run(["git", "config", "user.email", "github-actions@github.com"], check=True)
        subprocess.run(["git", "add", "pubspec.yaml"], check=True)
        subprocess.run(["git", "commit", "-m", f"chore: bump {DEPENDENCY} to v{site_version}"], check=True, capture_output=True, text=True)
        subprocess.run(["git", "push", "origin", branch], check=True, capture_output=True, text=True)
        print(f"✅ Pushed branch '{branch}' to origin.")

        subprocess.run(["git", "tag", "-a", tag, "-m", f"Release {DEPENDENCY} {site_version} ({release_date})"], check=True, capture_output=True, text=True)
        subprocess.run(["git", "push", "origin", tag], check=True, capture_output=True, text=True)
        print(f"✅ Pushed tag '{tag}' to origin.")
        
        body = f"""
        Automatic update of `{DEPENDENCY}` to version **{site_version}**.

        - 📅 **Release date:** {release_date}
        - 🔗 **Official Release Notes:** [{URL.replace('/api/v1/projects/', 'https://devcenter.unico.io/').replace('/docs/', '/')}]({URL.replace('/api/v1/projects/', 'https://devcenter.unico.io/').replace('/docs/', '/')})
        """

        subprocess.run([
            "gh", "pr", "create",
            "--title", f"chore: Update {DEPENDENCY} to v{site_version}",
            "--body", body,
            "--head", branch,
            "--base", "main" # Especifique a branch base, se necessário
        ], check=True, capture_output=True, text=True)
        print("✅ Successfully created Pull Request.")

    except subprocess.CalledProcessError as e:
        print(f"❌ An error occurred during git/gh operations:")
        print(f"   Command: {' '.join(e.cmd)}")
        print(f"   Stderr: {e.stderr}")
        exit(1)
    except FileNotFoundError:
        print("❌ Error: 'git' or 'gh' command not found. Make sure they are installed and in your PATH.")
        exit(1)

else:
    print("🔄 Dependency is already at the latest version. Nothing to do.")