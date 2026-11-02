# OneSignal & Google AdMob സജ്ജീകരണ സഹായി (Setup Guide)

ഈ ഗൈഡ് ഉപയോഗിച്ച് നിങ്ങളുടെ **Dweep Diary** ആപ്പിലേക്ക് തത്സമയ നോട്ടിഫിക്കേഷനുകളും ഗൂഗിൾ പരസ്യങ്ങളും എളുപ്പത്തിൽ ആക്റ്റീവ് ചെയ്യാം.

---

## ഭാഗം 1: OneSignal പുഷ് നോട്ടിഫിക്കേഷൻസ് (സൗജന്യം)

നിങ്ങൾ വേർഡ്പ്രസ്സിൽ വാർത്ത പബ്ലിഷ് ചെയ്യുമ്പോൾ തന്നെ എല്ലാ ആപ്പ് ഉപയോക്താക്കൾക്കും ഫോട്ടോയും തലക്കെട്ടും അടങ്ങിയ നോട്ടിഫിക്കേഷൻ തനിയെ വരാൻ:

### ഘട്ടം 1: OneSignal അക്കൗണ്ട് ഉണ്ടാക്കുക
1. **[onesignal.com](https://onesignal.com)** സന്ദർശിച്ച് ഒരു സൗജന്യ അക്കൗണ്ട് രജിസ്റ്റർ ചെയ്യുക.
2. **New App/Website** ക്ലിക്ക് ചെയ്യുക.
3. ആപ്പിന്റെ പേര്: `Dweep Diary` എന്ന് നൽകുക.
4. പ്ലാറ്റ്‌ഫോം: **Google Android (FCM)** തിരഞ്ഞെടുക്കുക.
5. പൂർത്തിയായ ശേഷം **Settings > Keys & IDs** എന്നതിൽ പോയാൽ നിങ്ങൾക്ക് **OneSignal App ID** ലഭിക്കും. (ഉദാ: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).

### ഘട്ടം 2: ആപ്പിലേക്ക് App ID ചേർക്കുക
1. നിങ്ങളുടെ പ്രോജക്റ്റിലെ [`lib/constants/app_constants.dart`](file:///c:/Users/hp/Downloads/dweepdiary/lib/constants/app_constants.dart) തുറക്കുക.
2. `oneSignalAppId` എന്നതിന് നേരെ നിങ്ങളുടെ ലഭിച്ച App ID പേസ്റ്റ് ചെയ്യുക:
   ```dart
   static const String oneSignalAppId = 'നിങ്ങളുടെ_ONESIGNAL_APP_ID';
   ```

### ഘട്ടം 3: വേർഡ്പ്രസ്സിൽ കണക്ട് ചെയ്യുക (Auto-Send Notifications)
1. നിങ്ങളുടെ **WordPress Admin Panel** തുറക്കുക (`dweepdiary.in/wp-admin`).
2. **Plugins > Add New** എടുക്കുക.
3. **OneSignal – Web Push Notifications** എന്ന് സെർച്ച് ചെയ്ത് ഇൻസ്റ്റാൾ ചെയ്ത് **Activate** ചെയ്യുക.
4. OneSignal Settings-ൽ നിങ്ങളുടെ OneSignal App ID നൽകി സേവ് ചെയ്യുക.
5. **തീർന്നു!** ഇനി നിങ്ങൾ വേർഡ്പ്രസ്സിൽ വാർത്ത "Publish" ചെയ്യുമ്പോൾ ആപ്പുള്ള എല്ലാവർക്കും നോട്ടിഫിക്കേഷൻ വരും!

---

## ഭാഗം 2: Google AdMob പരസ്യ വരുമാനം

### ഘട്ടം 1: AdMob അക്കൗണ്ട് തുറക്കുക
1. **[admob.google.com](https://admob.google.com)** സന്ദർശിച്ച് നിങ്ങളുടെ ജിമെയിൽ അക്കൗണ്ട് വെച്ച് ലോഗിൻ ചെയ്യുക.
2. **Apps > Add App** ക്ലിക്ക് ചെയ്യുക.
3. പ്ലാറ്റ്‌ഫോം: **Android** സെലക്ട് ചെയ്യുക.
4. ആപ്പിന്റെ പേര് `Dweep Diary` എന്ന് നൽകുക.
5. നിങ്ങൾക്ക് ഒരു **AdMob App ID** ലഭിക്കും (ഉദാ: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`).

### ഘട്ടം 2: Ad Units ഉണ്ടാക്കുക
ആപ്പിലെ പരസ്യങ്ങൾക്കായി 2 പ്രധാന Ad Units ഉണ്ടാക്കുക:
1. **Banner Ad:** (വാർത്തകൾക്ക് താഴെ വരുന്ന ബാനർ പരസ്യം).
2. **Interstitial Ad:** (വാർത്തകൾ മാറിമാറി വായിക്കുമ്പോൾ വരുന്ന ഫുൾ സ്ക്രീൻ പരസ്യം).

ഓരോന്നിനും ലഭിക്കുന്ന Ad Unit ID-കൾ (`ca-app-pub-xxxxxxxx/zzzzzzzz`) കോപ്പി ചെയ്യുക.

### ഘട്ടം 3: ആപ്പിൽ ഐഡികൾ ചേർക്കുക
1. [`lib/constants/app_constants.dart`](file:///c:/Users/hp/Downloads/dweepdiary/lib/constants/app_constants.dart) തുറക്കുക.
2. ഈ ഐഡികൾ അപ്‌ഡേറ്റ് ചെയ്യുക:
   ```dart
   static const String adMobBannerIdAndroid = 'നിങ്ങളുടെ_BANNER_AD_UNIT_ID';
   static const String adMobInterstitialIdAndroid = 'നിങ്ങളുടെ_INTERSTITIAL_AD_UNIT_ID';
   ```
3. [`android/app/src/main/AndroidManifest.xml`](file:///c:/Users/hp/Downloads/dweepdiary/android/app/src/main/AndroidManifest.xml) തുറന്ന് നിങ്ങളുടെ `com.google.android.gms.ads.APPLICATION_ID` മാറ്റുക.
