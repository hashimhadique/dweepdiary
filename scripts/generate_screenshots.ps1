# PowerShell Script to generate 5 high-converting Google Play Store promotional screenshots (1080 x 1920)
Add-Type -AssemblyName System.Drawing

$outFolder = "C:\Users\hp\Downloads\playstore_assets\screenshots"
if (!(Test-Path $outFolder)) { New-Item -ItemType Directory -Path $outFolder -Force }
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$logoUri = "file:///C:/Users/hp/Downloads/dweepdiary/assets/images/logo.png"
$iconUri = "file:///C:/Users/hp/Downloads/dweepdiary/assets/images/app_icon.png"
$islandImgUri = "file:///C:/Users/hp/Downloads/magnific__create-a-premium-lakshadweep-travel-promotional-po__95398.png"

$commonHead = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anek+Malayalam:wght@400;600;700;800;900&family=Poppins:wght@500;600;700;800;900&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body {
  width: 1080px;
  height: 1920px;
  overflow: hidden;
  font-family: 'Poppins', 'Anek Malayalam', sans-serif;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.bg-circle-1 {
  position: absolute;
  top: -100px;
  right: -100px;
  width: 550px;
  height: 550px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 180, 216, 0.35) 0%, rgba(0, 119, 182, 0) 70%);
  filter: blur(40px);
}
.bg-circle-2 {
  position: absolute;
  bottom: 200px;
  left: -150px;
  width: 600px;
  height: 600px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(114, 9, 183, 0.25) 0%, rgba(3, 4, 94, 0) 70%);
  filter: blur(50px);
}
.header-section {
  width: 100%;
  padding: 80px 60px 40px 60px;
  text-align: center;
  z-index: 10;
}
.promo-badge {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.18);
  border: 1px solid rgba(255, 255, 255, 0.35);
  backdrop-filter: blur(12px);
  padding: 10px 24px;
  border-radius: 40px;
  color: #fff;
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.8px;
  margin-bottom: 22px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}
.promo-title {
  font-family: 'Anek Malayalam', sans-serif;
  font-size: 50px;
  font-weight: 900;
  color: #ffffff;
  line-height: 1.25;
  margin-bottom: 12px;
  text-shadow: 0 4px 20px rgba(0,0,0,0.3);
}
.promo-sub {
  font-family: 'Poppins', sans-serif;
  font-size: 24px;
  font-weight: 600;
  color: #d1ecf1;
  letter-spacing: 0.5px;
}

/* Phone Frame */
.device-container {
  width: 860px;
  height: 1450px;
  background: #111827;
  border-radius: 56px 56px 0 0;
  padding: 16px 16px 0 16px;
  box-shadow: 0 -10px 80px rgba(0,0,0,0.5), 0 30px 100px rgba(0,0,0,0.6);
  border: 4px solid rgba(255, 255, 255, 0.25);
  border-bottom: none;
  position: relative;
  z-index: 10;
}
.device-screen {
  width: 100%;
  height: 100%;
  background: #f8fafc;
  border-radius: 44px 44px 0 0;
  overflow: hidden;
  position: relative;
  display: flex;
  flex-direction: column;
}
.status-bar {
  height: 48px;
  background: #ffffff;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 32px;
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
}
.notch {
  width: 110px;
  height: 24px;
  background: #000;
  border-radius: 14px;
}
.app-bar {
  background: #ffffff;
  height: 72px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid #e2e8f0;
}
.app-bar-logo {
  height: 40px;
}
.app-bar-icons {
  display: flex;
  gap: 16px;
  align-items: center;
  color: #0284c7;
  font-size: 22px;
}
</style>
</head>
"@

# Define 5 Screens Data
$screens = @(
  @{
    Id = 1
    File = "$outFolder\screenshot_1_home.png"
    BgGradient = "linear-gradient(160deg, #0077b6 0%, #03045e 100%)"
    Badge = "🔴 തത്സമയ വാർത്തകൾ"
    Title = "ലക്ഷദ്വീപിലെ വാർത്തകൾ വിരൽത്തുമ്പിൽ"
    Subtitle = "Breaking News, Ticker & Live Island Updates"
    Content = @"
      <!-- News Ticker -->
      <div style="background: #e0f2fe; padding: 12px 20px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #bae6fd;">
        <span style="background: #0284c7; color: white; padding: 4px 10px; border-radius: 6px; font-size: 13px; font-weight: 800; letter-spacing: 0.5px;">LATEST</span>
        <span style="font-family:'Anek Malayalam'; font-size: 16px; font-weight: 700; color: #0369a1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;">
          ലക്ഷദ്വീപിൽ പുതിയ അതിവേഗ യാത്രാക്കപ്പൽ സർവീസ് ആരംഭിച്ചു...
        </span>
        <span style="font-size: 12px; font-weight: 700; color: #0284c7;">1/5</span>
      </div>

      <!-- Category Tabs -->
      <div style="display: flex; gap: 10px; padding: 16px 20px; overflow: hidden;">
        <div style="background: #0284c7; color: white; padding: 8px 20px; border-radius: 20px; font-size: 15px; font-weight: 700;">All</div>
        <div style="background: #e2e8f0; color: #475569; padding: 8px 18px; border-radius: 20px; font-size: 15px; font-weight: 600;">News</div>
        <div style="background: #e2e8f0; color: #475569; padding: 8px 18px; border-radius: 20px; font-size: 15px; font-weight: 600;">Politics</div>
        <div style="background: #e2e8f0; color: #475569; padding: 8px 18px; border-radius: 20px; font-size: 15px; font-weight: 600;">Jobs</div>
        <div style="background: #e2e8f0; color: #475569; padding: 8px 18px; border-radius: 20px; font-size: 15px; font-weight: 600;">Features</div>
      </div>

      <!-- Main Hero News Card -->
      <div style="margin: 0 20px 16px 20px; background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 6px 20px rgba(0,0,0,0.06); border: 1px solid #f1f5f9;">
        <div style="position: relative; height: 260px; overflow: hidden;">
          <img src="$islandImgUri" style="width: 100%; height: 100%; object-fit: cover;" />
          <div style="position: absolute; top: 14px; left: 14px; background: rgba(2, 132, 199, 0.9); color: white; padding: 4px 12px; border-radius: 8px; font-size: 13px; font-weight: 800;">FEATURED</div>
          <div style="position: absolute; bottom: 12px; right: 14px; background: rgba(0,0,0,0.7); color: white; padding: 4px 10px; border-radius: 6px; font-size: 12px;">📍 Kavaratti</div>
        </div>
        <div style="padding: 18px;">
          <h2 style="font-family:'Anek Malayalam'; font-size: 23px; font-weight: 800; color: #0f172a; line-height: 1.4; margin-bottom: 10px;">
            ലക്ഷദ്വീപിൽ വിനോദസഞ്ചാര വികസനത്തിന് പുതിയ പദ്ധതികൾ; ഇന്റർ-ഐലൻഡ് ഗതാഗതം കൂടുതൽ ശക്തമാക്കും
          </h2>
          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 13px; color: #64748b; font-weight: 600;">
            <span>🕒 15 mins ago • News Desk</span>
            <span style="color: #0284c7; font-weight: 700;">Read More →</span>
          </div>
        </div>
      </div>

      <!-- Second News Card -->
      <div style="margin: 0 20px; background: white; border-radius: 18px; padding: 16px; display: flex; gap: 16px; box-shadow: 0 4px 16px rgba(0,0,0,0.04); border: 1px solid #f1f5f9;">
        <div style="flex: 1;">
          <span style="background: #f0fdf4; color: #16a34a; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 800;">JOB ALERT</span>
          <h3 style="font-family:'Anek Malayalam'; font-size: 17px; font-weight: 700; color: #1e293b; line-height: 1.4; margin-top: 6px;">
            ലക്ഷദ്വീപ് അഡ്മിനിസ്ട്രേഷനിൽ വിവിധ ഒഴിവുകളിലേക്ക് അപേക്ഷ ക്ഷണിച്ചു
          </h3>
          <span style="font-size: 12px; color: #94a3b8; margin-top: 6px; display: block;">1 hour ago</span>
        </div>
        <div style="width: 100px; height: 100px; background: #e2e8f0; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 32px;">💼</div>
      </div>
"@
  },
  @{
    Id = 2
    File = "$outFolder\screenshot_2_article_audio.png"
    BgGradient = "linear-gradient(160deg, #023e8a 0%, #0077b6 50%, #0096c7 100%)"
    Badge = "🎧 ഓഡിയോ ന്യൂസ് റീഡർ"
    Title = "വാർത്തകൾ വായിക്കാം, കേൾക്കാം!"
    Subtitle = "Anek Malayalam Typography & Built-in Audio Player"
    Content = @"
      <!-- Article Header Bar -->
      <div style="background: white; padding: 14px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9;">
        <div style="font-size: 18px; color: #0284c7; font-weight: 800;">← Back</div>
        <div style="display: flex; gap: 18px; font-size: 20px; color: #475569;">
          <span>🔊</span>
          <span>🔖</span>
          <span>📤</span>
        </div>
      </div>

      <!-- Article Image -->
      <div style="height: 280px; position: relative;">
        <img src="$islandImgUri" style="width: 100%; height: 100%; object-fit: cover;" />
        <div style="position: absolute; bottom: 14px; left: 16px; background: #0284c7; color: white; padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 800;">NEWS</div>
      </div>

      <!-- Article Content -->
      <div style="padding: 22px 24px; background: white; flex: 1;">
        <h1 style="font-family:'Anek Malayalam'; font-size: 26px; font-weight: 900; color: #0f172a; line-height: 1.35; margin-bottom: 14px;">
          ലക്ഷദ്വീപിലെ വികസന പദ്ധതികൾക്ക് പുതിയ വേഗത; വിനോദസഞ്ചാര മേഖലയിൽ വൻ മുന്നേറ്റം
        </h1>
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 18px; font-size: 13px; color: #64748b;">
          <span>✍️ എഡിറ്റോറിയൽ ഡെസ്ക്</span>
          <span>•</span>
          <span>🕒 3 min read</span>
          <span>•</span>
          <span>📅 Today</span>
        </div>
        <p style="font-family:'Anek Malayalam'; font-size: 18px; line-height: 1.7; color: #334155; margin-bottom: 16px;">
          ലക്ഷദ്വീപിലെ വിവിധ ദ്വീപുകളിലെ അടിസ്ഥാന സൗകര്യങ്ങൾ വികസിപ്പിക്കുന്നതിനും യാത്രാസൗകര്യങ്ങൾ വർദ്ധിപ്പിക്കുന്നതിനുമുള്ള പുതിയ പദ്ധതികൾ അഡ്മിനിസ്ട്രേഷൻ പ്രഖ്യാപിച്ചു. കപ്പൽ സർവീസുകൾ കൂടുതൽ സുഗമമാക്കുന്നതിനും...
        </p>

        <!-- Floating Audio Player -->
        <div style="background: linear-gradient(135deg, #0284c7, #0369a1); border-radius: 18px; padding: 18px 22px; color: white; display: flex; align-items: center; gap: 16px; box-shadow: 0 10px 25px rgba(2, 132, 199, 0.35); margin-top: 20px;">
          <div style="width: 52px; height: 52px; background: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; color: #0284c7; box-shadow: 0 4px 10px rgba(0,0,0,0.15);">
            ▶
          </div>
          <div style="flex: 1;">
            <div style="font-family:'Anek Malayalam'; font-size: 17px; font-weight: 800;">വാർത്ത കേൾക്കാം (Audio Reader)</div>
            <div style="height: 6px; background: rgba(255,255,255,0.3); border-radius: 3px; margin: 8px 0 6px 0; position: relative;">
              <div style="width: 45%; height: 100%; background: #38bdf8; border-radius: 3px;"></div>
            </div>
            <div style="display: flex; justify-content: space-between; font-size: 12px; color: #e0f2fe;">
              <span>01:15</span>
              <span>02:45</span>
            </div>
          </div>
          <div style="background: rgba(255,255,255,0.2); padding: 4px 10px; border-radius: 8px; font-size: 13px; font-weight: 800;">1.0x</div>
        </div>
      </div>
"@
  },
  @{
    Id = 3
    File = "$outFolder\screenshot_3_ship_updates.png"
    BgGradient = "linear-gradient(160deg, #0077b6 0%, #0096c7 40%, #03045e 100%)"
    Badge = "🚢 കപ്പൽ സർവീസ് അറിയിപ്പുകൾ"
    Title = "കപ്പൽ സർവീസുകൾ & ലൈവ് അലർട്ടുകൾ"
    Subtitle = "Real-time HSC Fleet Schedules & IRCTC Live Alerts"
    Content = @"
      <!-- Page Header -->
      <div style="background: white; padding: 16px 20px; border-bottom: 1px solid #f1f5f9;">
        <h2 style="font-family:'Anek Malayalam'; font-size: 22px; font-weight: 800; color: #0f172a;">Ship Updates & Alerts</h2>
        <p style="font-size: 13px; color: #64748b;">ലക്ഷദ്വീപ് കപ്പൽ സർവീസ് സമയവിവരങ്ങൾ</p>
      </div>

      <!-- Live IRCTC Banner -->
      <div style="margin: 16px 20px; background: #fef2f2; border: 1.5px solid #fecaca; border-radius: 16px; padding: 14px 16px; display: flex; align-items: center; gap: 14px;">
        <span style="font-size: 24px;">🚨</span>
        <div style="flex: 1;">
          <div style="font-size: 12px; font-weight: 800; color: #dc2626; letter-spacing: 0.5px;">IRCTC LIVE ANNOUNCEMENT</div>
          <div style="font-family:'Anek Malayalam'; font-size: 15px; font-weight: 700; color: #991b1b; margin-top: 2px;">
            ഇന്റർ-ഐലൻഡ് ഹൈസ്പീഡ് ക്രാഫ്റ്റുകൾ സാധാരണ സർവീസ് നടത്തുന്നു
          </div>
        </div>
      </div>

      <!-- Fleet List Section -->
      <div style="padding: 0 20px;">
        <div style="font-size: 14px; font-weight: 800; color: #475569; letter-spacing: 0.8px; margin-bottom: 12px;">HSC FAST SPEED CRAFTS</div>

        <!-- Ship Card 1 -->
        <div style="background: white; border-radius: 16px; padding: 16px; margin-bottom: 12px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; gap: 14px; align-items: center;">
            <div style="width: 48px; height: 48px; background: #e0f2fe; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px;">🚤</div>
            <div>
              <div style="font-size: 17px; font-weight: 800; color: #0f172a;">HSC VALIYAPANI</div>
              <div style="font-size: 13px; color: #64748b; font-weight: 600;">Kavaratti ⇄ Agatti</div>
            </div>
          </div>
          <span style="background: #dcfce7; color: #15803d; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 800;">● ON SCHEDULE</span>
        </div>

        <!-- Ship Card 2 -->
        <div style="background: white; border-radius: 16px; padding: 16px; margin-bottom: 12px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; gap: 14px; align-items: center;">
            <div style="width: 48px; height: 48px; background: #e0f2fe; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px;">🚤</div>
            <div>
              <div style="font-size: 17px; font-weight: 800; color: #0f172a;">HSC CHERIYAPANI</div>
              <div style="font-size: 13px; color: #64748b; font-weight: 600;">Amini ⇄ Kadmat</div>
            </div>
          </div>
          <span style="background: #dcfce7; color: #15803d; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 800;">● ON SCHEDULE</span>
        </div>

        <!-- Ship Card 3 -->
        <div style="background: white; border-radius: 16px; padding: 16px; margin-bottom: 12px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; gap: 14px; align-items: center;">
            <div style="width: 48px; height: 48px; background: #e0f2fe; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px;">🚤</div>
            <div>
              <div style="font-size: 17px; font-weight: 800; color: #0f172a;">HSC PERALI</div>
              <div style="font-size: 13px; color: #64748b; font-weight: 600;">Andrott ⇄ Kalpeni</div>
            </div>
          </div>
          <span style="background: #dcfce7; color: #15803d; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 800;">● ON SCHEDULE</span>
        </div>

        <!-- Ship Card 4 -->
        <div style="background: white; border-radius: 16px; padding: 16px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; gap: 14px; align-items: center;">
            <div style="width: 48px; height: 48px; background: #e0f2fe; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px;">🛳️</div>
            <div>
              <div style="font-size: 17px; font-weight: 800; color: #0f172a;">MV KAVARATTI</div>
              <div style="font-size: 13px; color: #64748b; font-weight: 600;">Kochi ⇄ Lakshadweep Islands</div>
            </div>
          </div>
          <span style="background: #e0f2fe; color: #0284c7; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 800;">IRCTC BOOKING</span>
        </div>
      </div>
"@
  },
  @{
    Id = 4
    File = "$outFolder\screenshot_4_jobs.png"
    BgGradient = "linear-gradient(160deg, #0f172a 0%, #0077b6 60%, #0284c7 100%)"
    Badge = "💼 തൊഴിൽ വാർത്തകൾ"
    Title = "ലക്ഷദ്വീപിലെ തൊഴിലവസരങ്ങൾ"
    Subtitle = "Government, Private & Island Career Notifications"
    Content = @"
      <!-- Page Header -->
      <div style="background: white; padding: 16px 20px; border-bottom: 1px solid #f1f5f9;">
        <h2 style="font-family:'Anek Malayalam'; font-size: 22px; font-weight: 800; color: #0f172a;">Jobs & Career Opportunities</h2>
        <p style="font-size: 13px; color: #64748b;">ഏറ്റവും പുതിയ തൊഴിൽ വിജ്ഞാപനങ്ങൾ</p>
      </div>

      <!-- Categories with Jobs highlighted -->
      <div style="display: flex; gap: 10px; padding: 16px 20px;">
        <div style="background: #e2e8f0; color: #475569; padding: 8px 18px; border-radius: 20px; font-size: 15px; font-weight: 600;">All</div>
        <div style="background: #e2e8f0; color: #475569; padding: 8px 18px; border-radius: 20px; font-size: 15px; font-weight: 600;">News</div>
        <div style="background: #e2e8f0; color: #475569; padding: 8px 18px; border-radius: 20px; font-size: 15px; font-weight: 600;">Politics</div>
        <div style="background: #0284c7; color: white; padding: 8px 22px; border-radius: 20px; font-size: 15px; font-weight: 700; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3);">Jobs ★</div>
      </div>

      <div style="padding: 0 20px;">
        <!-- Job Card 1 -->
        <div style="background: white; border-radius: 18px; padding: 20px; margin-bottom: 14px; border: 1.5px solid #0284c7; box-shadow: 0 6px 18px rgba(2, 132, 199, 0.08);">
          <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
            <span style="background: #f0fdf4; color: #16a34a; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 800;">NEW OPENING</span>
            <span style="font-size: 13px; color: #dc2626; font-weight: 700;">Last Date: 25 Nov</span>
          </div>
          <h3 style="font-family:'Anek Malayalam'; font-size: 19px; font-weight: 800; color: #0f172a; line-height: 1.4; margin-bottom: 8px;">
            ലക്ഷദ്വീപ് അഡ്മിനിസ്ട്രേഷനിൽ വിവിധ തസ്തികകളിലേക്ക് അപേക്ഷ ക്ഷണിച്ചു
          </h3>
          <div style="font-size: 13px; color: #64748b; margin-bottom: 12px;">
            🏢 ഡിപ്പാർട്ട്മെന്റ്: ജനറൽ അഡ്മിനിസ്ട്രേഷൻ & വിദ്യാഭ്യാസം
          </div>
          <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #f1f5f9; padding-top: 12px;">
            <span style="font-size: 13px; color: #0284c7; font-weight: 700;">യോഗ്യത: ഡിഗ്രി / ഡിപ്ലോമ</span>
            <span style="background: #0284c7; color: white; padding: 6px 16px; border-radius: 8px; font-size: 13px; font-weight: 700;">Apply Now</span>
          </div>
        </div>

        <!-- Job Card 2 -->
        <div style="background: white; border-radius: 18px; padding: 20px; margin-bottom: 14px; border: 1px solid #e2e8f0;">
          <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
            <span style="background: #eff6ff; color: #2563eb; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 800;">HEALTH SERVICES</span>
            <span style="font-size: 13px; color: #64748b; font-weight: 600;">Walk-in Interview</span>
          </div>
          <h3 style="font-family:'Anek Malayalam'; font-size: 18px; font-weight: 800; color: #0f172a; line-height: 1.4; margin-bottom: 8px;">
            ലക്ഷദ്വീപ് ഹെൽത്ത് സർവീസിൽ സ്റ്റാഫ് നഴ്സ് & ലാബ് ടെക്നീഷ്യൻ ഒഴിവുകൾ
          </h3>
          <div style="font-size: 13px; color: #64748b;">
            📍 ഇൻഡിരാ ഗാന്ധി ഹോസ്പിറ്റൽ, കവരത്തി
          </div>
        </div>

        <!-- Job Card 3 -->
        <div style="background: white; border-radius: 18px; padding: 20px; border: 1px solid #e2e8f0;">
          <h3 style="font-family:'Anek Malayalam'; font-size: 18px; font-weight: 800; color: #0f172a; line-height: 1.4; margin-bottom: 6px;">
            ദ്വീപുകളിലെ സ്കൂളുകളിൽ ഗസ്റ്റ് അധ്യാപക നിയമനം
          </h3>
          <div style="font-size: 13px; color: #64748b;">
            📚 വിഷയം: മാത്തമാറ്റിക്സ്, സയൻസ്, ഇംഗ്ലീഷ്
          </div>
        </div>
      </div>
"@
  },
  @{
    Id = 5
    File = "$outFolder\screenshot_5_submit_news.png"
    BgGradient = "linear-gradient(160deg, #0077b6 0%, #03045e 50%, #0f172a 100%)"
    Badge = "📸 ജനകീയ വാർത്തകൾ"
    Title = "വാർത്തകളും ചിത്രങ്ങളും നേരിട്ട് അയക്കാം"
    Subtitle = "Instant Citizen Reporting via WhatsApp Editorial Desk"
    Content = @"
      <!-- Page Header -->
      <div style="background: white; padding: 16px 20px; border-bottom: 1px solid #f1f5f9;">
        <h2 style="font-family:'Anek Malayalam'; font-size: 22px; font-weight: 800; color: #0f172a;">Submit News (വാർത്തകൾ അയക്കാം)</h2>
        <p style="font-size: 13px; color: #64748b;">നിങ്ങളുടെ ദ്വീപിലെ വാർത്തകളും ചിത്രങ്ങളും പങ്കുവെക്കൂ</p>
      </div>

      <!-- Notice Card -->
      <div style="margin: 16px 20px; background: #f0fdf4; border: 1.5px solid #bbf7d0; border-radius: 16px; padding: 14px 16px; display: flex; gap: 12px;">
        <span style="font-size: 24px;">🛡️</span>
        <div>
          <div style="font-size: 13px; font-weight: 800; color: #15803d;">EDITORIAL VERIFICATION</div>
          <div style="font-family:'Anek Malayalam'; font-size: 14px; color: #166534; margin-top: 2px;">
            നിങ്ങൾ നൽകുന്ന വാർത്തകളും ചിത്രങ്ങളും എഡിറ്റോറിയൽ ഡെസ്ക് പരിശോധിച്ച് ഉറപ്പുവരുത്തിയ ശേഷം പ്രസിദ്ധീകരിക്കുന്നു.
          </div>
        </div>
      </div>

      <!-- Form Preview -->
      <div style="padding: 0 20px;">
        <!-- Attached Photos Preview -->
        <div style="font-size: 13px; font-weight: 700; color: #475569; margin-bottom: 8px;">ATTACHED PHOTOS (2 Selected)</div>
        <div style="display: flex; gap: 12px; margin-bottom: 16px;">
          <div style="width: 100px; height: 90px; border-radius: 12px; overflow: hidden; position: relative; border: 2px solid #0284c7;">
            <img src="$islandImgUri" style="width: 100%; height: 100%; object-fit: cover;" />
            <div style="position: absolute; top: 4px; right: 4px; background: red; color: white; width: 18px; height: 18px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px;">✕</div>
          </div>
          <div style="width: 100px; height: 90px; border-radius: 12px; overflow: hidden; position: relative; border: 2px solid #0284c7;">
            <img src="$islandImgUri" style="width: 100%; height: 100%; object-fit: cover; filter: hue-rotate(90deg);" />
            <div style="position: absolute; top: 4px; right: 4px; background: red; color: white; width: 18px; height: 18px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px;">✕</div>
          </div>
          <div style="width: 100px; height: 90px; border-radius: 12px; border: 2px dashed #cbd5e1; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #0284c7; background: white;">
            <span style="font-size: 24px;">📷</span>
            <span style="font-size: 11px; font-weight: 700; margin-top: 2px;">+ Add</span>
          </div>
        </div>

        <!-- Headline Input -->
        <div style="background: white; border: 1.5px solid #cbd5e1; border-radius: 12px; padding: 14px; margin-bottom: 12px;">
          <div style="font-size: 11px; color: #64748b; font-weight: 700;">HEADLINE</div>
          <div style="font-family:'Anek Malayalam'; font-size: 16px; font-weight: 700; color: #0f172a; margin-top: 4px;">
            കവരത്തിയിൽ അന്താരാഷ്ട്ര സമുദ്ര സുരക്ഷാ സെമിനാർ സംഘടിപ്പിച്ചു
          </div>
        </div>

        <!-- Island & Details -->
        <div style="background: white; border: 1.5px solid #cbd5e1; border-radius: 12px; padding: 14px; margin-bottom: 20px;">
          <div style="font-size: 11px; color: #64748b; font-weight: 700;">LOCATION</div>
          <div style="font-size: 15px; font-weight: 700; color: #0f172a; margin-top: 4px;">📍 Kavaratti Island</div>
        </div>

        <!-- Big WhatsApp Button -->
        <div style="background: #25D366; color: white; padding: 18px; border-radius: 16px; display: flex; align-items: center; justify-content: center; gap: 12px; font-size: 18px; font-weight: 800; box-shadow: 0 8px 24px rgba(37, 211, 102, 0.4);">
          <span style="font-size: 26px;">💬</span>
          <span>Send to WhatsApp Desk (+91 8289883750)</span>
        </div>
      </div>
"@
  }
)

foreach ($s in $screens) {
  Write-Host "Rendering Screenshot $($s.Id): $($s.Title)..."
  $html = @"
$commonHead
<body style="background: $($s.BgGradient);">
  <div class="bg-circle-1"></div>
  <div class="bg-circle-2"></div>

  <div class="header-section">
    <div class="promo-badge">$($s.Badge)</div>
    <div class="promo-title">$($s.Title)</div>
    <div class="promo-sub">$($s.Subtitle)</div>
  </div>

  <div class="device-container">
    <div class="device-screen">
      <div class="status-bar">
        <span>09:41</span>
        <div class="notch"></div>
        <span>100% 🔋</span>
      </div>

      <div class="app-bar">
        <img src="$logoUri" class="app-bar-logo" />
        <div class="app-bar-icons">
          <span>🌙</span>
          <span>🔔</span>
        </div>
      </div>

      $($s.Content)
    </div>
  </div>
</body>
</html>
"@

  $tempHtml = "$env:TEMP\screen_$($s.Id).html"
  [System.IO.File]::WriteAllText($tempHtml, $html)
  
  $targetPng = $s.File
  & $edge --headless=new --disable-gpu --window-size=1080,1920 --screenshot="$targetPng" "file:///$($tempHtml.Replace('\', '/'))"
  Start-Sleep -Seconds 1
  Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue

  if (Test-Path $targetPng) {
    Write-Host "SUCCESS: Generated $($targetPng) ($((Get-Item $targetPng).Length) bytes)"
  } else {
    Write-Host "FAILED to generate $($targetPng)"
  }
}

Write-Host "All Screenshots Complete in $outFolder"
Get-ChildItem -Path $outFolder -Filter "*.png" | Select-Object Name, Length | Format-Table -AutoSize
