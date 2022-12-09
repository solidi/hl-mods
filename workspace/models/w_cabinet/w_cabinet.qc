$modelname "w_cabinet.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures

$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "w_cabinet"

$texturegroup ice
{
  {
    "k.o.bmp"
  }
  {
    "invert_k.o.bmp"
  }
  {
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "root" -18.00000 -18.00000 -72.000000 18.00000 18.00000 72.000000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
