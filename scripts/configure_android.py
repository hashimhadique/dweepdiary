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
        
    with open(settings_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("SUCCESS: android/settings.gradle updated with Kotlin 1.9.24")

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

    content = re.sub(r'minSdkVersion\s*=\s*flutter\.minSdkVersion', 'minSdkVersion = 24', content)
    content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24', content)
    content = re.sub(r'minSdk\s+\d+', 'minSdk 24', content)

    if 'multiDexEnabled' not in content:
        content = content.replace('defaultConfig {', 'defaultConfig {\n        multiDexEnabled true')

    # Configure Production Release Signing Key
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

    content = content.replace('signingConfig signingConfigs.debug', 'signingConfig signingConfigs.release')

    with open(app_gradle, 'w', encoding='utf-8') as f:
        f.write(content)
    print("SUCCESS: android/app/build.gradle updated with minSdk 24, multiDex, and Production Release Signing")

# 4. Update AndroidManifest.xml for AdMob and Permissions
manifest_file = os.path.join('android', 'app', 'src', 'main', 'AndroidManifest.xml')
if os.path.exists(manifest_file):
    with open(manifest_file, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'android:usesCleartextTraffic' not in content:
        content = content.replace('<application', '<application\n        android:usesCleartextTraffic="true"')

    admob_tag = '        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-9969872629451816~3787335139"/>\n'
    if 'com.google.android.gms.ads.APPLICATION_ID' not in content:
        content = content.replace('</application>', admob_tag + '    </application>')

    perms = '''    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
'''
    if 'android.permission.POST_NOTIFICATIONS' not in content:
        content = content.replace('<application', perms + '    <application')

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

    with open(manifest_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print("SUCCESS: AndroidManifest.xml updated with AdMob, permissions, and Deep Links")

print("--- Android Configuration Complete! ---")
