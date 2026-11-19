<#
.SYNOPSIS
  1:1 texture-name swap for a Valve220 .map, driven by a swaps CSV (old,new,fit,group).
.DESCRIPTION
  fit=0 keeps the face's offsets/scales byte-identical (how the human reskins were done).
  fit=1 rescales so the new texture covers the same world area as the old one
  (scale /= new/old size, offset *= new/old size) - use for panels, crates, decals-like art.
  Texture sizes are read from the WADs in -WadsDir, first-wins in Compile-Map's wads.cfg order,
  so a name duplicated across WADs resolves to the copy hlcsg will actually use.
  Always run against the untouched original map so the swap stays reproducible.

  Optional fix-up inputs (applied in the same pass, also against the original):
  -FaceOverrides CSV  plane,texture,align   one face, matched by its three-point plane string
                      "( x y z ) ( x y z ) ( x y z )"; align (optional) replaces "[ u ] [ v ] rot su sv".
  -EntityEdits CSV    classname,key,match,newkey,newvalue   match is the current value or *;
                      empty newkey keeps the key, empty newvalue keeps the value (= key rename).
  -AddEntities file   raw entity blocks appended to the end of the map (env_snow, trigger_mp3audio...).
.EXAMPLE
  pwsh .\powershell\Retexture-Map.ps1 -In orig.map -Out add-ons\frost_party\maps\frost_party\frost_party.map `
    -Swaps .\ai\retexture\frost_party_swaps.csv -SkyName cirnightmont1
#>
param(
  [Parameter(Mandatory)][string]$In,
  [Parameter(Mandatory)][string]$Out,
  [Parameter(Mandatory)][string]$Swaps,
  [string]$WadsDir = "$PSScriptRoot\..\wads",
  [string]$SkyName,
  [string]$Wad,
  [string]$FaceOverrides,
  [string]$EntityEdits,
  [string]$AddEntities
)
$ErrorActionPreference = 'Stop'
$wadOrder = 'coldice','datafloe','thetemple','glacialcore','latenightxmas','storm','decals','halflife','icerink','liquids','spacepirate','spraypaint','xeno'
$texSize = @{}
foreach ($w in $wadOrder) {
  $p = Join-Path $WadsDir "$w.wad"; if (-not (Test-Path $p)) { continue }
  $data = [IO.File]::ReadAllBytes($p)
  $n = [BitConverter]::ToInt32($data, 4); $dir = [BitConverter]::ToInt32($data, 8)
  for ($i = 0; $i -lt $n; $i++) {
    $e = $dir + $i * 32; $fp = [BitConverter]::ToInt32($data, $e)
    $name = [Text.Encoding]::ASCII.GetString($data, $e + 16, 16).Split([char]0)[0].ToLower()
    if (-not $texSize.ContainsKey($name)) { $texSize[$name] = @([double][BitConverter]::ToInt32($data, $fp + 16), [double][BitConverter]::ToInt32($data, $fp + 20), $w) }
  }
}
$map = @{}; Import-Csv $Swaps | ForEach-Object { $map[$_.old.ToLower()] = $_ }
foreach ($s in $map.Values) { if (-not $texSize.ContainsKey($s.new.ToLower())) { throw "texture $($s.new) is not in any compile WAD" } }

$rx = [regex]'^(\s*\(.*?\)\s*\(.*?\)\s*\(.*?\)\s*)(\S+)(\s*\[\s*)(\S+) (\S+) (\S+) (\S+)(\s*\]\s*\[\s*)(\S+) (\S+) (\S+) (\S+)(\s*\]\s*)(\S+) (\S+) (\S+)(.*)$'
$inv = [Globalization.CultureInfo]::InvariantCulture
function F([double]$x) { [Math]::Round($x, 4).ToString('0.####', $inv) }
function PlaneKey([string]$t) { ($t.Trim() -replace '\s+', ' ') }
$faceOv = @{}; if ($FaceOverrides) { Import-Csv $FaceOverrides | ForEach-Object { $faceOv[(PlaneKey $_.plane)] = $_ } }
$entEd = @(); if ($EntityEdits) { $entEd = @(Import-Csv $EntityEdits) }
foreach ($f in $faceOv.Values) { if (-not $texSize.ContainsKey($f.texture.ToLower())) { throw "override texture $($f.texture) is not in any compile WAD" } }
$faceHit = @{}; $entHit = @{}

function Convert-Face([string]$l) {
  $m = $rx.Match($l)
  if (-not $m.Success) { return $l }
  $g = $m.Groups; $old = $g[2].Value.ToLower()
  if ($map.ContainsKey($old)) {
    $s = $map[$old]; $new = $s.new.ToLower()
    if ($s.fit -ne '1') {
      $l = $g[1].Value + $new.ToUpper() + $l.Substring($g[2].Index + $g[2].Length)
    } else {
      if (-not $texSize.ContainsKey($old)) { throw "fit needs the size of $old" }
      $ku = $texSize[$new][0] / $texSize[$old][0]; $kv = $texSize[$new][1] / $texSize[$old][1]
      $uo = [double]::Parse($g[7].Value, $inv) * $ku; $vo = [double]::Parse($g[12].Value, $inv) * $kv
      $su = [double]::Parse($g[15].Value, $inv) / $ku; $sv = [double]::Parse($g[16].Value, $inv) / $kv
      $l = $g[1].Value + $new.ToUpper() + $g[3].Value + "$($g[4].Value) $($g[5].Value) $($g[6].Value) $(F $uo)" + $g[8].Value +
           "$($g[9].Value) $($g[10].Value) $($g[11].Value) $(F $vo)" + $g[13].Value + "$($g[14].Value) $(F $su) $(F $sv)" + $g[17].Value
    }
    $script:count[$old] = 1 + [int]$script:count[$old]
    $m = $rx.Match($l); $g = $m.Groups
  }
  $key = PlaneKey $g[1].Value
  if ($faceOv.ContainsKey($key)) {
    $o = $faceOv[$key]; $rest = if ($o.align) { ' ' + $o.align.Trim() } else { $l.Substring($g[2].Index + $g[2].Length) }
    $l = $g[1].Value + $o.texture.ToUpper() + $rest
    $script:faceHit[$key] = 1 + [int]$script:faceHit[$key]
  }
  return $l
}

function Flush-Entity([Collections.Generic.List[string]]$kv) {
  $cls = ''; foreach ($k in $kv) { if ($k -match '^"classname" "([^"]*)"') { $cls = $matches[1] } }
  for ($i = 0; $i -lt $kv.Count; $i++) {
    if ($kv[$i] -notmatch '^"([^"]*)" "([^"]*)"$') { continue }
    $key = $matches[1]; $val = $matches[2]
    if ($SkyName -and $cls -eq 'worldspawn' -and $key -eq 'skyname') { $val = $SkyName }
    if ($Wad -and $cls -eq 'worldspawn' -and $key -eq 'wad') { $val = $Wad }
    foreach ($e in $entEd) {
      if ($e.classname -ne $cls -or $e.key -ne $key -or ($e.match -ne '*' -and $e.match -ne $val)) { continue }
      if ($e.newkey) { $key = $e.newkey }; if ($e.newvalue) { $val = $e.newvalue }
      $id = "$($e.classname)|$($e.key)|$($e.match)"; $script:entHit[$id] = 1 + [int]$script:entHit[$id]
      break
    }
    $kv[$i] = "`"$key`" `"$val`""
  }
  foreach ($k in $kv) { [void]$script:sb.Append($k).Append("`r`n") }
  $kv.Clear()
}

$count = @{}; $sb = New-Object Text.StringBuilder; $depth = 0; $kv = New-Object 'Collections.Generic.List[string]'
foreach ($l in [IO.File]::ReadLines($In)) {
  $t = $l.Trim()
  if ($t -eq '{') { if ($depth -eq 1) { Flush-Entity $kv }; $depth++; [void]$sb.Append($l).Append("`r`n"); continue }
  if ($t -eq '}') { if ($depth -eq 1) { Flush-Entity $kv }; $depth--; [void]$sb.Append($l).Append("`r`n"); continue }
  if ($depth -eq 1 -and $t.StartsWith('"')) { $kv.Add($l); continue }
  [void]$sb.Append((Convert-Face $l)).Append("`r`n")
}
if ($AddEntities) { $extra = (Get-Content $AddEntities -Raw).Trim() -replace "`r?`n", "`r`n"; [void]$sb.Append($extra).Append("`r`n") }
[IO.File]::WriteAllText($Out, $sb.ToString(), [Text.Encoding]::ASCII)
$count.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { '{0,5} {1} -> {2} ({3})' -f $_.Value, $_.Key, $map[$_.Key].new, $texSize[$map[$_.Key].new.ToLower()][2] }
foreach ($k in $map.Keys) { if (-not $count.ContainsKey($k)) { Write-Warning "swap $k matched no faces" } }
foreach ($k in $faceOv.Keys) { if ($faceHit.ContainsKey($k)) { "face override: $($faceOv[$k].texture) x$($faceHit[$k])" } else { Write-Warning "face override matched nothing: $k" } }
foreach ($e in $entEd) { $id = "$($e.classname)|$($e.key)|$($e.match)"; if ($entHit.ContainsKey($id)) { "entity edit: $id x$($entHit[$id])" } else { Write-Warning "entity edit matched nothing: $id" } }
'total faces swapped: ' + ($count.Values | Measure-Object -Sum).Sum
