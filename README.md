# Dweep Diary Mobile App (www.dweepdiary.in)

ലക്ഷദ്വീപിന്റെ പ്രമുഖ വാർത്താ പോർട്ടലായ **Dweep Diary**-ക്ക് വേണ്ടി നിർമ്മിച്ച ഒഫീഷ്യൽ ഹൈ-പെർഫോമൻസ് മൊബൈൽ ആപ്ലിക്കേഷൻ (Android & iOS).

---

## 📱 പ്രധാന സവിശേഷതകൾ (Key Features)

1. **തത്സമയ വേർഡ്പ്രസ്സ് സിങ്ക് (Live WordPress Sync):**
   * `dweepdiary.in` വെബ്‌സൈറ്റിലെ REST API വഴി വാർത്തകളും ചിത്രങ്ങളും തത്സമയം ആപ്പിൽ ലഭ്യമാകുന്നു.
2. **സ്കൈ ബ്ലൂ & വൈറ്റ് പ്രീമിയം തീം (Sky Blue & White Design):**
   * ലക്ഷദ്വീപിന്റെ തനതായ കടലിന്റെയും ആകാശത്തിന്റെയും വർണ്ണങ്ങൾ പ്രതിഫലിപ്പിക്കുന്ന കളർ തീം.
3. **ബ്രേക്കിംഗ് ന്യൂസ് സ്ലൈഡറും ഫ്ലാഷ് ടിക്കറും:**
   * ഹോം സ്ക്രീനിൽ പ്രധാന വാർത്തകളുടെ ആനിമേഷൻ കാറോസൽ സ്ലൈഡർ.
4. **കാറ്റഗറി ഫിൽട്ടറിംഗ് (Dynamic Category Tabs):**
   * NEWS, POLITICS, FEATURE STORIES, EDUCATION, RELIGIOUS, SPORTS, LITERATURE, EDITORIAL, JOBS, DEATH.
5. **ഓഡിയോ ന്യൂസ് (Text-to-Speech):**
   * വാർത്തകൾ വായിക്കുന്നതിന് പകരം മലയാളത്തിൽ കേൾക്കാനുള്ള സ്പീക്കർ ബട്ടൺ.
6. **അക്ഷര വലുപ്പം ക്രമീകരിക്കാം ($A^+$ / $A^-$ Font Sizer):**
   * വായനക്കാർക്ക് അവരുടെ സൗകര്യത്തിനനുസരിച്ച് ഫോണ്ട് സൈസ് മാറ്റാം.
7. **ഇൻഷോർട്ട്സ് മോഡൽ (Vertical Swipe News):**
   * റീൽസ് പോലെ മുകളിലേക്ക് സ്വൈപ്പ് ചെയ്ത് 60 വാക്കുകളിൽ വാർത്തകൾ വേഗത്തിൽ വായിക്കാം.
8. **ഓഫ്‌ലൈൻ വായനയും ബുക്ക്മാർക്കുകളും (Offline Bookmarks):**
   * ഇഷ്ടപ്പെട്ട വാർത്തകൾ സേവ് ചെയ്തുവെക്കാനും നെറ്റ് ഇല്ലാത്തപ്പോഴും വായിക്കാനും സാധിക്കും.
9. **വൺ-ക്ലിക്ക് വാട്സാപ്പ് ഷെയറിംഗ് (WhatsApp Share):**
   * വാർത്തയുടെ തലക്കെട്ടും ഫോട്ടോയും ലിങ്കും ഒറ്റ ക്ലിക്കിൽ വാട്സാപ്പിൽ പങ്കുവെക്കാം.
10. **പരസ്യ വരുമാനം (Monetization Ready):**
    * Google AdMob Banner, Interstitial, Native Ads സപ്പോർട്ട്.
    * കൂടാതെ ലക്ഷദ്വീപിലെ പ്രാദേശിക സ്ഥാപനങ്ങളുടെ സ്പോൺസേർഡ് ബാനറുകൾ നേരിട്ട് നൽകാനുള്ള സ്ലോട്ട്.

---

## 📁 പ്രോജക്റ്റ് ഘടന (Project Structure)

```
dweepdiary/
├── assets/
│   └── images/
│       ├── logo.png         <-- Dweep Diary ഒഫീഷ്യൽ ലോഗോ
│       └── app_icon.png     <-- ആപ്പ് ഐക്കൺ
├── lib/
│   ├── main.dart            <-- ആപ്പ് ആരംഭിക്കുന്ന മെയിൻ ഫയൽ
│   ├── constants/
│   │   ├── app_colors.dart  <-- സ്കൈ ബ്ലൂ & വൈറ്റ് കളർ പാലറ്റ്
│   │   └── app_constants.dart <-- API, AdMob, ലിങ്കുകൾ
│   ├── models/
│   │   ├── post_model.dart  <-- വാർത്തകളുടെ ഡാറ്റാ മോഡൽ
│   │   └── category_model.dart
│   ├── services/
│   │   ├── api_service.dart <-- വെബ്സൈറ്റിൽ നിന്ന് വാർത്തകൾ എടുക്കുന്ന സർവീസ്
│   │   ├── bookmark_service.dart <-- ഓഫ്‌ലൈൻ സേവിംഗ്
│   │   └── tts_service.dart <-- വോയ്സ് റീഡർ
│   ├── widgets/
│   │   ├── ad_banner_widget.dart <-- AdMob & സ്പോൺസേർഡ് പരസ്യങ്ങൾ
│   │   ├── breaking_news_ticker.dart
│   │   ├── category_tabs.dart
│   │   ├── featured_slider.dart
│   │   └── news_card.dart
│   └── screens/
│       ├── home_screen.dart
│       ├── main_navigation_screen.dart
│       ├── news_detail_screen.dart
│       ├── shorts_news_screen.dart
│       ├── bookmarks_screen.dart
│       └── search_screen.dart
```

---

## 🚀 ആപ്പ് റൺ ചെയ്യുന്ന വിധം (How to Run)

നിങ്ങളുടെ കമ്പ്യൂട്ടറിൽ Flutter ഇൻസ്റ്റാൾ ചെയ്തിട്ടുണ്ടെങ്കിൽ:

```bash
# 1. പാക്കേജുകൾ ഡൗൺലോഡ് ചെയ്യുക
flutter pub get

# 2. മൊബൈൽ ഫോൺ അല്ലെങ്കിൽ എമുലേറ്റർ കണക്ട് ചെയ്ത് റൺ ചെയ്യുക
flutter run
```

---

## 💰 ഗൂഗിൾ AdMob പരസ്യങ്ങൾ ആക്റ്റീവ് ചെയ്യുന്ന വിധം

നിലവിൽ ടെസ്റ്റിംഗിനായുള്ള Google Test Ad IDs ആണ് ആപ്പിൽ ഉള്ളത്. നിങ്ങളുടെ സ്വന്തം AdMob അക്കൗണ്ടിൽ നിന്നുള്ള പരസ്യങ്ങൾ കാണിക്കാൻ:

1. `lib/constants/app_constants.dart` തുറക്കുക.
2. `adMobBannerIdAndroid`, `adMobInterstitialIdAndroid` എന്നിവ നിങ്ങളുടെ സ്വന്തം AdMob Unit ID-കൾ വെച്ച് റീപ്ലേസ് ചെയ്യുക.
3. `android/app/src/main/AndroidManifest.xml` ഫയലിലെ `com.google.android.gms.ads.APPLICATION_ID` എന്നതിന് പകരം നിങ്ങളുടെ AdMob App ID നൽകുക.

---

## 📦 പ്ലേ സ്റ്റോറിലേക്ക് APK / App Bundle ബിൽഡ് ചെയ്യാൻ:

```bash
# പ്ലേ സ്റ്റോറിന് വേണ്ടിയുള്ള App Bundle (.aab) ഉണ്ടാക്കാൻ:
flutter build appbundle --release

# മൊബൈലിൽ ഇൻസ്റ്റാൾ ചെയ്ത് നേരിട്ട് ടെസ്റ്റ് ചെയ്യാൻ APK ഉണ്ടാക്കാൻ:
flutter build apk --release
```
