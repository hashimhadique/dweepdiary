import re
import os

print("--- Configuring Android Project for Dweep Diary ---")

# 1. Update android/settings.gradle to Kotlin 1.9.24
settings_file = os.path.join('android', 'settings.gradle')
if os.path.exists(settings_file):
    with open(settings_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace kotlin android version with 1.9.24
    new_content = re.sub(
        r'id\s*\(?["\']org\.jetbrains\.kotlin\.android["\']\)?\s*version\s*["\'][^"\']+["\']',
        'id "org.jetbrains.kotlin.android" version "1.9.24"',
        content
    )
    # If not matched by regex, perform fallback string replace
    if new_content == content:
        new_content = re.sub(r'version\s*["\']1\.[0-9]+\.[0-9]+["\']', 'version "1.9.24"', content)
        
    with open(settings_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("SUCCESS: android/settings.gradle updated with Kotlin 1.9.24")

# 2. Update android/app/build.gradle for minSdk 24 and multiDex
app_gradle = os.path.join('android', 'app', 'build.gradle')
if os.path.exists(app_gradle):
    with open(app_gradle, 'r', encoding='utf-8') as f:
        content = f.read()

    content = re.sub(r'minSdkVersion\s*=\s*flutter\.minSdkVersion', 'minSdkVersion = 24', content)
    content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24', content)
    content = re.sub(r'minSdk\s+\d+', 'minSdk 24', content)

    if 'multiDexEnabled' not in content:
        content = content.replace('defaultConfig {', 'defaultConfig {\n        multiDexEnabled true')

    with open(app_gradle, 'w', encoding='utf-8') as f:
        f.write(content)
    print("SUCCESS: android/app/build.gradle updated with minSdk 24 and multiDex")

# 3. Update AndroidManifest.xml for AdMob and Permissions
manifest_file = os.path.join('android', 'app', 'src', 'main', 'AndroidManifest.xml')
if os.path.exists(manifest_file):
    with open(manifest_file, 'r', encoding='utf-8') as f:
        content = f.read()

    admob_tag = '        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-9969872629451816~3787335139"/>\n'
    if 'com.google.android.gms.ads.APPLICATION_ID' not in content:
        content = content.replace('</application>', admob_tag + '    </application>')

    perms = '    <uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>\n'
    if 'android.permission.INTERNET' not in content:
        content = content.replace('<application', perms + '    <application')

    with open(manifest_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print("SUCCESS: AndroidManifest.xml updated with AdMob and permissions")

print("--- Android Configuration Complete! ---")
