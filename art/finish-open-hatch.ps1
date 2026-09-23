Add-Type -AssemblyName System.Drawing
$source = [System.Drawing.Bitmap]::FromFile('C:\Steam games ideas\toner-terror\art\balcao-claro-aberto-recorte-v2.png')
$closed = [System.Drawing.Bitmap]::FromFile('C:\Steam games ideas\toner-terror\art\balcao-claro-fechado-recorte-v1.png')
$result = $source.Clone([System.Drawing.Rectangle]::new(0,0,$source.Width,$source.Height),[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($result)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
function Wood-Face($coords, $shade) {
 $points = [System.Drawing.Point[]]@($coords | ForEach-Object { [System.Drawing.Point]::new($_[0],$_[1]) })
 $texture = [System.Drawing.TextureBrush]::new($closed)
 $g.FillPolygon($texture,$points)
 $texture.Dispose()
 $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($shade,35,20,9))
 $g.FillPolygon($brush,$points)
 $brush.Dispose()
 $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255,57,38,25),1)
 $g.DrawPolygon($pen,$points)
 $pen.Dispose()
}
# Solid exposed end-grain of the right countertop, not an empty clipped edge.
Wood-Face @(@(330,758),@(355,690),@(355,706),@(330,774)) 55
# Restore the supporting upright all the way up to the countertop lip.
Wood-Face @(@(317,774),@(330,759),@(330,941),@(317,941)) 35
# Restore the fixed left section's narrow landing under the hinge.
Wood-Face @(@(79,758),@(122,710),@(122,726),@(79,775)) 65
# Add the raised leaf's thickness on its free vertical edge and upper edge.
$edge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255,105,65,38))
$g.FillPolygon($edge,[System.Drawing.Point[]]@([System.Drawing.Point]::new(59,518),[System.Drawing.Point]::new(64,521),[System.Drawing.Point]::new(84,756),[System.Drawing.Point]::new(79,758)))
$edge.Dispose()
$lip = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255,201,149,92),2)
$g.DrawLine($lip,60,518,119,451)
$lip.Dispose()
$g.Dispose()
$target = 'C:\Steam games ideas\toner-terror\art\balcao-claro-aberto-acabado-v3.png'
if(Test-Path -LiteralPath $target) { throw 'Output already exists' }
$result.Save($target,[System.Drawing.Imaging.ImageFormat]::Png)
$source.Dispose(); $closed.Dispose(); $result.Dispose()
Write-Output $target
