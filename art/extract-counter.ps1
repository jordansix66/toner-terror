Add-Type -AssemblyName System.Drawing
$sourcePath = 'C:\Users\jbord\AppData\Local\Temp\codex-clipboard-7fefcdfd-de6a-4cd4-902e-dfb3e172ad33.png'
$outputPath = 'C:\Steam games ideas\toner-terror\art\balcao-claro-fechado-recorte-v1.png'
if (Test-Path -LiteralPath $outputPath) { throw 'Output already exists.' }
$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
if ($source.Width -ne 1672 -or $source.Height -ne 941) { throw 'Unexpected source dimensions.' }
$result = New-Object System.Drawing.Bitmap($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($result)
$graphics.DrawImageUnscaled($source, 0, 0)
$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Transparent)
function Clear-Polygon($coordinates) {
    $points = [System.Drawing.Point[]] @($coordinates | ForEach-Object { New-Object System.Drawing.Point($_[0], $_[1]) })
    $graphics.FillPolygon($brush, $points)
}
# Follow the existing top silhouette; retain original RGB pixels below it.
Clear-Polygon @(@(0,0),@(1672,0),@(1672,721),@(1651,700),@(1646,690),@(1244,690),@(1240,696),@(1237,690),@(139,690),@(0,694))
# Empty passage below the closed lifting hatch, excluding its wooden side.
Clear-Polygon @(@(123,775),@(316,775),@(316,941),@(78,941),@(122,880))
$graphics.Dispose()
$brush.Dispose()
$result.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$transparent = 0
$retained = 0
$changed = 0
for ($y=0; $y -lt $source.Height; $y++) {
    for ($x=0; $x -lt $source.Width; $x++) {
        $pixel = $result.GetPixel($x,$y)
        if ($pixel.A -eq 0) { $transparent++ }
        else {
            $retained++
            if ($pixel.ToArgb() -ne $source.GetPixel($x,$y).ToArgb()) { $changed++ }
        }
    }
}
Write-Output "Size: $($result.Width)x$($result.Height); transparent pixels: $transparent; retained pixels: $retained; changed retained pixels: $changed"
$result.Dispose()
$source.Dispose()
