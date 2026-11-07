$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$screenshotDir = "C:\Users\hp\Downloads\playstore_assets\screenshots"

if (-not (Test-Path $screenshotDir)) {
    New-Item -ItemType Directory -Force -Path $screenshotDir | Out-Null
}

1..5 | ForEach-Object {
    $num = $_
    $htmlPath = "file:///C:/Users/hp/Downloads/playstore_assets/templates/screenshot_$num.html"
    $pngPath = "$screenshotDir\screenshot_$num.png"
    Write-Host "Rendering screenshot $num to $pngPath ..."
    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--disable-gpu',
        '--hide-scrollbars',
        '--window-size=1080,1920',
        "--screenshot=$pngPath",
        $htmlPath
    ) -Wait -NoNewWindow
}

Get-ChildItem -Path $screenshotDir | Select-Object Name, Length, LastWriteTime
