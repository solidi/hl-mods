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
  [string]$Wad
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
$count = @{}; $sb = New-Object Text.StringBuilder
foreach ($l in [IO.File]::ReadLines($In)) {
  if ($SkyName -and $l -match '^"skyname" ') { $l = "`"skyname`" `"$SkyName`"" }
  elseif ($Wad -and $l -match '^"wad" ') { $l = "`"wad`" `"$Wad`"" }
  else {
    $m = $rx.Match($l)
    if ($m.Success -and $map.ContainsKey($m.Groups[2].Value.ToLower())) {
      $g = $m.Groups; $old = $g[2].Value.ToLower(); $s = $map[$old]; $new = $s.new.ToLower()
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
      $count[$old] = 1 + [int]$count[$old]
    }
  }
  [void]$sb.Append($l).Append("`r`n")
}
[IO.File]::WriteAllText($Out, $sb.ToString(), [Text.Encoding]::ASCII)
$count.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { '{0,5} {1} -> {2} ({3})' -f $_.Value, $_.Key, $map[$_.Key].new, $texSize[$map[$_.Key].new.ToLower()][2] }
foreach ($k in $map.Keys) { if (-not $count.ContainsKey($k)) { Write-Warning "swap $k matched no faces" } }
'total faces swapped: ' + ($count.Values | Measure-Object -Sum).Sum
