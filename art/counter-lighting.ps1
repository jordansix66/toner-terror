Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class CounterLighting {
 static int Clamp(double v) { return Math.Max(0,Math.Min(255,(int)Math.Round(v))); }
 public static void Make(string input,string output,bool dark) {
  using(var src=new Bitmap(input))
  using(var dst=new Bitmap(src.Width,src.Height,PixelFormat.Format32bppArgb)) {
   for(int y=0;y<src.Height;y++) for(int x=0;x<src.Width;x++) {
    Color c=src.GetPixel(x,y);
    if(c.A==0) { dst.SetPixel(x,y,c); continue; }
    double r,g,b;
    if(dark) {
     // Near blackout: faint cool ambient illumination, no glowing glass highlights.
     r=c.R*.072; g=c.G*.105; b=c.B*.165;
    } else {
     // Warm overhead light on the top, cooler and dimmer on vertical faces.
     double top=1.0-Math.Min(1.0,Math.Max(0.0,(y-752)/45.0));
     r=c.R*(.52+.22*top)+2;
     g=c.G*(.49+.12*top)+3;
     b=c.B*(.61-.16*top)+7;
    }
    dst.SetPixel(x,y,Color.FromArgb(c.A,Clamp(r),Clamp(g),Clamp(b)));
   }
   dst.Save(output,ImageFormat.Png);
   int alphaChanges=0;
   for(int y=0;y<src.Height;y++) for(int x=0;x<src.Width;x++)
    if(src.GetPixel(x,y).A!=dst.GetPixel(x,y).A) alphaChanges++;
   Console.WriteLine("{0}: {1}x{2}, alpha differences = {3}",output,dst.Width,dst.Height,alphaChanges);
  }
 }
}
'@
$artFolder = 'C:\Steam games ideas\toner-terror\art'
$inputCounter = Join-Path $artFolder 'balcao-claro-fechado-recorte-v1.png'
foreach($state in @('medio','escuro')) {
 $outputCounter = Join-Path $artFolder "balcao-$state-fechado-recorte-v1.png"
 if(Test-Path -LiteralPath $outputCounter) { throw 'Output already exists' }
 [CounterLighting]::Make($inputCounter,$outputCounter,($state -eq 'escuro'))
}
