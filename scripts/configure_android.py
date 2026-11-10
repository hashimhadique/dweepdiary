import re
import os

print("--- Configuring Android Project for Dweep Diary ---")

# 1. Update android/settings.gradle to Kotlin 1.9.24
settings_file = os.path.join('android', 'settings.gradle')
if os.path.exists(settings_file):
    with open(settings_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = re.sub(
        r'id\s*\(?["\']org\.jetbrains\.kotlin\.android["\']\)?\s*version\s*["\'][^"\']+["\']',
        'id "org.jetbrains.kotlin.android" version "1.9.24"',
        content
    )
    if new_content == content:
        new_content = re.sub(r'version\s*["\']1\.[0-9]+\.[0-9]+["\']', 'version "1.9.24"', content)
        
    if 'com.google.gms.google-services' not in new_content:
        new_content = new_content.replace('plugins {', 'plugins {\n    id "com.google.gms.google-services" version "4.4.2" apply false')

    with open(settings_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("SUCCESS: android/settings.gradle updated with Kotlin 1.9.24 and Google Services plugin")

# 2. Update android/build.gradle to force stdlib resolution and skip metadata check
build_gradle = os.path.join('android', 'build.gradle')
if os.path.exists(build_gradle):
    with open(build_gradle, 'r', encoding='utf-8') as f:
        bg_content = f.read()

    extra_rules = """
allprojects {
    configurations.all {
        resolutionStrategy {
            force "org.jetbrains.kotlin:kotlin-stdlib:1.9.24"
            force "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.24"
            force "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.24"
        }
    }
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
        kotlinOptions {
            freeCompilerArgs += [
                "-Xskip-metadata-version-check"
            ]
        }
    }
}
"""
    bg_content = bg_content + "\n" + extra_rules
    with open(build_gradle, 'w', encoding='utf-8') as f:
        f.write(bg_content)
    print("SUCCESS: android/build.gradle configured with compiler flags & forced stdlib 1.9.24")

# 3. Update android/app/build.gradle for minSdk 24 and multiDex
app_gradle = os.path.join('android', 'app', 'build.gradle')
if os.path.exists(app_gradle):
    with open(app_gradle, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'com.google.gms.google-services' not in content:
        content = content.replace('plugins {', 'plugins {\n    id "com.google.gms.google-services"')

    content = re.sub(r'minSdkVersion\s*=\s*flutter\.minSdkVersion', 'minSdkVersion = 24', content)
    content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24', content)
    content = re.sub(r'minSdk\s+\d+', 'minSdk 24', content)

    # Target SDK 36 and Compile SDK 36 for Google Play Console requirement
    content = re.sub(r'compileSdk\s*=\s*\w+(\.\w+)?', 'compileSdk = 36', content)
    content = re.sub(r'compileSdk\s+flutter\.compileSdkVersion', 'compileSdk 36', content)
    content = re.sub(r'targetSdk\s*=\s*\w+(\.\w+)?', 'targetSdk = 36', content)
    content = re.sub(r'targetSdk\s+flutter\.targetSdkVersion', 'targetSdk 36', content)

    # Enforce package name in.dweepdiary.app
    content = re.sub(r'applicationId\s*=?\s*["\'][^"\']+["\']', 'applicationId "in.dweepdiary.app"', content)
    content = re.sub(r'namespace\s*=?\s*["\'][^"\']+["\']', 'namespace "in.dweepdiary.app"', content)

    if 'multiDexEnabled' not in content:
        content = content.replace('defaultConfig {', 'defaultConfig {\n        multiDexEnabled true')

    # Configure Production Release Signing Key and Native Debug Symbols
    signing_block = """
    signingConfigs {
        release {
            keyAlias 'upload'
            keyPassword 'dweepdiary2026'
            storeFile file('upload-keystore.jks')
            storePassword 'dweepdiary2026'
        }
    }
"""
    if 'signingConfigs {' not in content:
        content = content.replace('buildTypes {', signing_block + '\n    buildTypes {')

    # Replace any variation of debug signingConfig in release buildType (with or without '=')
    content = re.sub(r'signingConfig\s*=?\s*signingConfigs\.debug', 'signingConfig = signingConfigs.release', content)

    # Double check: ensure signingConfigs.release is explicitly attached to release buildType
    if 'signingConfigs.release' not in content:
        content = re.sub(r'(buildTypes\s*\{\s*release\s*\{)', r'\1\n            signingConfig = signingConfigs.release', content)

    # Add native debug symbols for Play Store
    if 'debugSymbolLevel' not in content:
        content = re.sub(r'(signingConfig\s*=?\s*signingConfigs\.release)', r'\1\n            ndk {\n                debugSymbolLevel "FULL"\n            }', content)

    with open(app_gradle, 'w', encoding='utf-8') as f:
        f.write(content)
    print("SUCCESS: android/app/build.gradle updated with minSdk 24, multiDex, and Production Release Signing")

    # Also create key.properties
    key_props = os.path.join('android', 'key.properties')
    with open(key_props, 'w', encoding='utf-8') as f:
        f.write("storePassword=dweepdiary2026\nkeyPassword=dweepdiary2026\nkeyAlias=upload\nstoreFile=upload-keystore.jks\n")
    print("SUCCESS: android/key.properties written")

# 4. Update AndroidManifest.xml for AdMob, Permissions, and App Launcher Name
manifest_file = os.path.join('android', 'app', 'src', 'main', 'AndroidManifest.xml')
if os.path.exists(manifest_file):
    with open(manifest_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Ensure App Name is permanently "Dweep Diary" on the launcher
    content = re.sub(r'android:label="[^"]*"', 'android:label="Dweep Diary"', content)

    if 'android:usesCleartextTraffic' not in content:
        content = content.replace('<application', '<application\n        android:usesCleartextTraffic="true"')

    admob_tag = '        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-9969872629451816~3787335139"/>\n'
    if 'com.google.android.gms.ads.APPLICATION_ID' not in content:
        content = content.replace('</application>', admob_tag + '    </application>')

    perms = '''    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
'''
    if 'android.permission.POST_NOTIFICATIONS' not in content:
        content = content.replace('<application', perms + '    <application')

    # Remove any media permissions to comply with Play Store photo picker policy
    content = re.sub(r'\s*<uses-permission android:name="android\.permission\.READ_MEDIA_IMAGES"\s*/>', '', content)
    content = re.sub(r'\s*<uses-permission android:name="android\.permission\.READ_EXTERNAL_STORAGE"\s*/>', '', content)
    content = re.sub(r'\s*<uses-permission android:name="android\.permission\.WRITE_EXTERNAL_STORAGE"\s*/>', '', content)

    deep_link_filters = '''            <!-- Deep Linking for dweepdiary.in and www.dweepdiary.in -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="http" android:host="dweepdiary.in" />
                <data android:scheme="https" android:host="dweepdiary.in" />
                <data android:scheme="http" android:host="www.dweepdiary.in" />
                <data android:scheme="https" android:host="www.dweepdiary.in" />
            </intent-filter>
            <!-- Custom scheme deep link: dweepdiary://... -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="dweepdiary" />
            </intent-filter>
'''
    if 'dweepdiary.in' not in content:
        content = content.replace('</activity>', deep_link_filters + '        </activity>')

    if 'package="in.dweepdiary.app"' not in content:
        content = re.sub(r'<manifest\s+xmlns:android="http://schemas.android.com/apk/res/android"', '<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n    package="in.dweepdiary.app"', content)

    with open(manifest_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print("SUCCESS: AndroidManifest.xml updated with AdMob, permissions, and Deep Links")

# 5. Ensure MainActivity.kt is located in in/dweepdiary/app
kt_target_dir = os.path.join('android', 'app', 'src', 'main', 'kotlin', 'in', 'dweepdiary', 'app')
os.makedirs(kt_target_dir, exist_ok=True)
kt_file = os.path.join(kt_target_dir, 'MainActivity.kt')
with open(kt_file, 'w', encoding='utf-8') as f:
    f.write("package `in`.dweepdiary.app\n\nimport io.flutter.embedding.android.FlutterActivity\n\nclass MainActivity: FlutterActivity()\n")

wrong_kt_dir = os.path.join('android', 'app', 'src', 'main', 'kotlin', 'in', 'dweepdiary', 'dweepdiary')
if os.path.exists(wrong_kt_dir):
    import shutil
    shutil.rmtree(wrong_kt_dir)
print("SUCCESS: MainActivity.kt configured under package in.dweepdiary.app")

print("--- Android Configuration Complete! ---")
