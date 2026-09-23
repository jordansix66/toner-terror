Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
public static class CounterHatch {
 public static void Make(string input, string output) {
  using(var src=new Bitmap(input))
  using(var dst=src.Clone(new Rectangle(0,0,src.Width,src.Height),PixelFormat.Format32bppArgb)) {
   // Remove only the closed moving leaf, including its front fascia.
   using(var g=Graphics.FromImage(dst)) {
    g.CompositingMode=CompositingMode.SourceCopy;
    g.SmoothingMode=SmoothingMode.None;
    using(var clear=new SolidBrush(Color.Transparent))
     g.FillPolygon(clear,new Point[]{new Point(80,758),new Point(139,690),new Point(355,690),new Point(330,758),new Point(330,775),new Point(80,775)});
   }
   // Map original leaf texture onto its raised plane, leaving the fixed hinge axis in place.
   // Hinge front=(79,758), hinge rear=(139,690); free edge rises 240px.
   for(int y=449;y<=758;y++) for(int x=58;x<=140;x++) {
    double dx=x-79, dy=y-758;
    double u=(-68*dx-60*dy)/15760.0;
    double v=(240*dx-20*dy)/15760.0;
    if(u<0||u>1||v<0||v>1) continue;
    double sx=79+60*v+u*(251-35*v);
    double sy=758-68*v;
    Color c=src.GetPixel(Math.Max(0,Math.Min(src.Width-1,(int)Math.Round(sx))),Math.Max(0,Math.Min(src.Height-1,(int)Math.Round(sy))));
    // Keep original color palette and wood texture; narrow original dark edges frame the leaf.
    if(u>.992 || v<.012 || v>.988) c=Color.FromArgb(255,57,40,28);
    dst.SetPixel(x,y,c);
   }
   dst.Save(output,ImageFormat.Png);
   int outside=0,total=0;
   for(int y=0;y<src.Height;y++) for(int x=0;x<src.Width;x++) {
    if(src.GetPixel(x,y).ToArgb()==dst.GetPixel(x,y).ToArgb()) continue;
    total++;
    if(x<58 || x>355 || y<449 || y>775) outside++;
   }
   Console.WriteLine("Dimensions: {0}x{1}; changed pixels: {2}; changed outside hatch region: {3}",src.Width,src.Height,total,outside);
  }
 }
}
'@
$hatchOutput = 'C:\Steam games ideas\toner-terror\art\balcao-claro-aberto-recorte-v2.png'
if(Test-Path -LiteralPath $hatchOutput) { throw 'Output already exists.' }
[CounterHatch]::Make('C:\Steam games ideas\toner-terror\art\balcao-claro-fechado-recorte-v1.png',$hatchOutput)
