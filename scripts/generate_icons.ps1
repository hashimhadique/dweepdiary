Add-Type -AssemblyName System.Drawing

# 1. Generate 512x512 App Icon
$size = 512
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Draw squircle / rounded rect background
$rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(255, 0, 180, 216), # Cyan
    [System.Drawing.Color]::FromArgb(255, 3, 4, 94),   # Deep Navy
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
)
$g.FillRectangle($gradBrush, $rect)

# Draw subtle lagoon wave curves
$wavePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 14)
$g.DrawArc($wavePen, -50, 200, 600, 300, 180, 180)
$g.DrawArc($wavePen, -100, 240, 700, 300, 180, 180)

# Draw Center Icon Badge (White rounded card with shadow)
$cardRect = New-Object System.Drawing.Rectangle(76, 76, 360, 360)
$cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(250, 255, 255, 255))
$cardPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 70
$cardPath.AddArc(76, 76, $radius, $radius, 180, 90)
$cardPath.AddArc(76 + 360 - $radius, 76, $radius, $radius, 270, 90)
$cardPath.AddArc(76 + 360 - $radius, 76 + 360 - $radius, $radius, $radius, 0, 90)
$cardPath.AddArc(76, 76 + 360 - $radius, $radius, $radius, 90, 90)
$cardPath.CloseFigure()
$g.FillPath($cardBrush, $cardPath)

# Inner Island Sun / Golden Badge
$goldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 158, 11))
$g.FillEllipse($goldBrush, 216, 110, 80, 80)

# Monogram "DD" in Sky Blue
$fontDD = New-Object System.Drawing.Font("Arial", 88, [System.Drawing.FontStyle]::Bold)
$ddBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 119, 182))
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("DD", $fontDD, $ddBrush, 256, 235, $sf)

# Tag "DWEEP DIARY"
$fontTag = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
$tagBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))
$g.DrawString("DWEEP DIARY", $fontTag, $tagBrush, 256, 340, $sf)

# Save App Icon
$bmp.Save("C:\Users\hp\Downloads\dweepdiary\assets\images\app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Host "SUCCESS: Generated 512x512 app_icon.png"

# 2. Generate Horizontal Logo for AppBar (300x70)
$logoBmp = New-Object System.Drawing.Bitmap(320, 80)
$lg = [System.Drawing.Graphics]::FromImage($logoBmp)
$lg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$lg.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Draw Icon circle on left
$circleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 153, 230))
$lg.FillEllipse($circleBrush, 6, 10, 60, 60)

# DD text inside icon circle
$smFontDD = New-Object System.Drawing.Font("Arial", 22, [System.Drawing.FontStyle]::Bold)
$wBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$lg.DrawString("DD", $smFontDD, $wBrush, 36, 40, $sf)

# "DWEEP DIARY" Text
$logoTitleFont = New-Object System.Drawing.Font("Arial", 22, [System.Drawing.FontStyle]::Bold)
$titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 119, 182))
$sfLeft = New-Object System.Drawing.StringFormat
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Near
$lg.DrawString("DWEEP DIARY", $logoTitleFont, $titleBrush, 76, 16, $sfLeft)

# Malayalam Tagline "?????? ????"
$mlFont = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
$mlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 116, 139))
$lg.DrawString("?????? ???? • LAKSHADWEEP", $mlFont, $mlBrush, 78, 48, $sfLeft)

$logoBmp.Save("C:\Users\hp\Downloads\dweepdiary\assets\images\logo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$lg.Dispose()
$logoBmp.Dispose()
Write-Host "SUCCESS: Generated logo.png"
