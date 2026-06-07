import os
import sys
import re
import subprocess
import json

# 1. Automatic dependency installation
def install_dependencies():
    required = {
        'google-api-python-client': 'googleapiclient',
        'google-auth-oauthlib': 'google_auth_oauthlib',
        'google-auth': 'google.auth'
    }
    missing = []
    import importlib
    for pkg, imp_name in required.items():
        try:
            importlib.import_module(imp_name)
        except ImportError:
            missing.append(pkg)
            
    if missing:
        print(f"Missing libraries: {missing}. Installing via pip...")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install"] + missing)
            print("Successfully installed missing libraries.\n")
        except Exception as e:
            print(f"Error installing dependencies: {e}")
            print("Please run manually: pip install google-api-python-client google-auth-oauthlib")
            sys.exit(1)

install_dependencies()

# Import the google API library modules after installation check
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

# Configuration
SCOPES = ['https://www.googleapis.com/auth/androidpublisher']
PACKAGE_NAME = 'com.shriharshkotecha.motherhood'
CLIENT_SECRETS_FILE = 'playstore-Oauth.json'
TOKEN_FILE = 'token.json'
PUBSPEC_PATH = 'pubspec.yaml'
AAB_PATH = os.path.join('build', 'app', 'outputs', 'bundle', 'release', 'app-release.aab')

SERVICE_ACCOUNT_FILES = ['playstore-service-account.json', 'firebase-key.json']

def authenticate():
    """Authenticates the user. Tries Service Account JSON first, falls back to OAuth client secrets."""
    # 1. Try Service Account
    for sa_file in SERVICE_ACCOUNT_FILES:
        if os.path.exists(sa_file):
            print(f"Found service account key file: '{sa_file}'. Authenticating via Service Account...")
            try:
                from google.oauth2 import service_account
                creds = service_account.Credentials.from_service_account_file(sa_file, scopes=SCOPES)
                print("Authenticated successfully using Service Account.")
                return creds, sa_file
            except Exception as e:
                print(f"Warning: Failed to authenticate with service account '{sa_file}': {e}")
                
    # 2. Fallback to OAuth 2.0 Client Secrets
    creds = None
    if os.path.exists(TOKEN_FILE):
        try:
            creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
            print("Loaded cached credentials from token.json.")
        except Exception as e:
            print(f"Warning: Failed to load cached token.json: {e}. Re-authenticating...")

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            print("Cached credentials expired. Refreshing token...")
            try:
                creds.refresh(Request())
            except Exception as e:
                print(f"Failed to refresh token: {e}. Performing full authentication...")
                creds = None
        
        if not creds:
            if not os.path.exists(CLIENT_SECRETS_FILE):
                print(f"Error: Credentials file '{CLIENT_SECRETS_FILE}' not found in the root directory.")
                print("Please ensure your Google Play OAuth client secrets file is present.")
                sys.exit(1)
            
            print("\nStarting Google OAuth2 authentication flow...")
            print("A web browser should open automatically to authorize this script.")
            print("If it does not open, please copy the URL printed below and open it manually.")
            
            flow = InstalledAppFlow.from_client_secrets_file(CLIENT_SECRETS_FILE, SCOPES)
            # Run local server to listen for the oauth callback
            creds = flow.run_local_server(host='127.0.0.1', port=0)
            
        # Save the token
        try:
            with open(TOKEN_FILE, 'w') as token:
                token.write(creds.to_json())
            print("Credentials successfully cached to token.json.")
        except Exception as e:
            print(f"Warning: Could not save credentials to token.json: {e}")
            
    return creds, None

def get_highest_version_code(service, sa_file=None):
    """Fetches the maximum uploaded version code for the package from Google Play."""
    print("Connecting to Google Play Developer Console to fetch current build versions...")
    try:
        # We must create an edit to list bundles
        edit = service.edits().insert(packageName=PACKAGE_NAME, body={}).execute()
        edit_id = edit['id']
        
        bundles_result = service.edits().bundles().list(
            packageName=PACKAGE_NAME, editId=edit_id
        ).execute()
        
        # Cleanup/Close the read-only edit
        service.edits().delete(packageName=PACKAGE_NAME, editId=edit_id).execute()
        
        bundles = bundles_result.get('bundles', [])
        if not bundles:
            print("No existing bundles found on Google Play for this package. Starting with version code 1.")
            return 0
            
        version_codes = [b['versionCode'] for b in bundles]
        max_code = max(version_codes)
        print(f"Highest version code found in Google Play Console: {max_code}")
        return max_code
        
    except HttpError as e:
        # Check if the error is package not found
        error_content = e.content.decode('utf-8') if e.content else ""
        if "applicationNotFound" in error_content or "not found" in error_content.lower():
            print(f"\n[Warning] Package '{PACKAGE_NAME}' was not found in the Google Play Console.")
            print("Please make sure you have created the application in the Play Console under this exact package name.")
            print("We will default the current Play Store version code to 0 and proceed.")
            return 0
        elif "permission" in error_content.lower() or "notAuthorized" in error_content or e.resp.status == 403:
            print("\n=======================================================")
            print(" ERROR: API Permission Denied (403)")
            print("=======================================================")
            if sa_file:
                try:
                    with open(sa_file, 'r') as f:
                        sa_data = json.load(f)
                        client_email = sa_data.get('client_email', 'unknown')
                    print(f"The service account '{client_email}' does not have permission to manage this app.")
                    print("\nTo fix this, please follow these steps:")
                    print("1. Log in to the Google Play Console.")
                    print("2. Navigate to 'Setup' > 'Users and permissions'.")
                    print("3. Click 'Invite new users' and invite this email:")
                    print(f"   {client_email}")
                    print("4. Under app permissions, ensure it has 'Release manager' permissions for the app.")
                    print("5. Save and send the invitation.")
                except Exception:
                    pass
            print(f"Details: {error_content}")
            sys.exit(1)
        else:
            print(f"Error fetching version codes from Google Play Developer API: {e}")
            print(f"Details: {error_content}")
            sys.exit(1)

def get_current_pubspec_version():
    """Reads the current version name and code from pubspec.yaml."""
    if not os.path.exists(PUBSPEC_PATH):
        print(f"Error: {PUBSPEC_PATH} not found in the current directory.")
        sys.exit(1)
        
    with open(PUBSPEC_PATH, 'r') as f:
        content = f.read()
        
    match = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)', content, re.MULTILINE)
    if not match:
        print("Error: Could not parse version in pubspec.yaml. Expected format: 'version: X.Y.Z+W'")
        sys.exit(1)
        
    version_name, version_code = match.groups()
    return version_name, int(version_code)

def update_pubspec_version(version_name, new_version_code):
    """Updates the version in pubspec.yaml with the new version code."""
    with open(PUBSPEC_PATH, 'r') as f:
        content = f.read()
        
    new_version_line = f"version: {version_name}+{new_version_code}"
    # Replace the version line
    updated_content = re.sub(
        r'^version:\s*\d+\.\d+\.\d+\+\d+',
        new_version_line,
        content,
        flags=re.MULTILINE
    )
    
    with open(PUBSPEC_PATH, 'w') as f:
        f.write(updated_content)
        
    print(f"Updated pubspec.yaml to version: {version_name}+{new_version_code}")

def build_appbundle():
    """Builds the release Android App Bundle using Flutter."""
    print("\nRunning 'flutter build appbundle --release'...")
    try:
        # Run clean first to avoid cached issues
        subprocess.run(["flutter", "clean"], check=True, shell=True)
        # Get packages
        subprocess.run(["flutter", "pub", "get"], check=True, shell=True)
        # Build bundle
        subprocess.run(["flutter", "build", "appbundle", "--release"], check=True, shell=True)
        print("Flutter appbundle build completed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error building Flutter appbundle: {e}")
        sys.exit(1)

def upload_bundle_and_release(service, new_version_code):
    """Uploads the build to Google Play Console and assigns it to the internal track."""
    print(f"\nStarting upload of {AAB_PATH} to Google Play Store...")
    
    if not os.path.exists(AAB_PATH):
        print(f"Error: Build file not found at {AAB_PATH}.")
        sys.exit(1)
        
    try:
        # 1. Create edit transaction
        print("Creating a new Google Play edit transaction...")
        edit = service.edits().insert(packageName=PACKAGE_NAME, body={}).execute()
        edit_id = edit['id']
        
        # 2. Upload the bundle
        print("Uploading app bundle (this may take a few minutes)...")
        media = MediaFileUpload(AAB_PATH, mimetype='application/octet-stream', resumable=True)
        bundle = service.edits().bundles().upload(
            packageName=PACKAGE_NAME,
            editId=edit_id,
            media_body=media
        ).execute()
        
        uploaded_version_code = bundle['versionCode']
        print(f"App Bundle uploaded successfully. Uploaded version code: {uploaded_version_code}")
        
        # Verify the version code matches
        if uploaded_version_code != new_version_code:
            print(f"Warning: Uploaded version code ({uploaded_version_code}) differs from expected ({new_version_code}).")
        
        # 3. Assign the bundle to the internal track
        print("Assigning uploaded bundle to the 'internal' testing track...")
        track_body = {
            'track': 'internal',
            'releases': [
                {
                    'versionCodes': [str(uploaded_version_code)],
                    'status': 'completed',
                    'name': f"Release {uploaded_version_code}"
                }
            ]
        }
        
        service.edits().tracks().update(
            packageName=PACKAGE_NAME,
            editId=edit_id,
            track='internal',
            body=track_body
        ).execute()
        
        # 4. Commit edit transaction
        print("Committing and finalizing the release edit transaction...")
        service.edits().commit(packageName=PACKAGE_NAME, editId=edit_id).execute()
        
        print("\n=======================================================")
        print(" SUCCESS: Build pushed to Google Play Internal Testing!")
        print("=======================================================")
        
    except HttpError as e:
        error_content = e.content.decode('utf-8') if e.content else ""
        print(f"\nAPI Error during upload/release: {e}")
        print(f"Details: {error_content}")
        print("Aborting transaction.")
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error during upload: {e}")
        sys.exit(1)

def main():
    print("==============================================")
    print(" Google Play Store Deployment Automation Tool ")
    print("==============================================\n")
    
    # 1. Authenticate with Google Developer Console
    creds, sa_file = authenticate()
    service = build('androidpublisher', 'v3', credentials=creds)
    
    # 2. Check current versions
    max_playstore_code = get_highest_version_code(service, sa_file)
    version_name, current_code = get_current_pubspec_version()
    
    print(f"Local version in pubspec.yaml: {version_name}+{current_code}")
    
    # 3. Handle version code increments if necessary
    new_version_code = current_code
    if current_code <= max_playstore_code:
        new_version_code = max_playstore_code + 1
        print(f"Auto-Incrementing local version code: {current_code} -> {new_version_code}")
        update_pubspec_version(version_name, new_version_code)
    else:
        print(f"Local version code ({current_code}) is already higher than Google Play's ({max_playstore_code}). No auto-increment needed.")
        
    # 4. Compile the bundle (using the pre-compiled bundle)
    build_appbundle()
    
    # 5. Upload and publish
    upload_bundle_and_release(service, new_version_code)

if __name__ == '__main__':
    main()
