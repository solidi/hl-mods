# Map Retexture ("Cold Ice reskin") Context

How Valve-style HLDM maps get their winter Cold Ice reskin, what was learned
from the existing reskins, and the state of each reskin done with
[`powershell/Retexture-Map.ps1`](../powershell/Retexture-Map.ps1). Read this
before reskinning a map, and add feedback from in-game testing here.

## 1. Style target (from the maintainer)

- Natural earth tones, the look of `coldice.wad`: stone, brick, rock, wood, snow.
- Swap hot colours (yellow, orange) for blue, white or red wherever an
  equivalent exists. Yellow lights become white. Yellow/black hazard stripes
  become red/white (`stripes4`/`stripes5` in halflife.wad).
- Be a little conservative: keep neutral greys, trims, signage, tool textures
  and anything functional (chargers, ladders, toggled lights).
- Best references: `training2` (from `training`), `snowyard` (from
  `stalkyard2`), `bounce2` (the only Xen/alien reskin, see §3).

## 2. How the human reskins were done (evidence)

- **A pure 1:1 name swap.** In the `yard` → `snowyard` commit (`5210221e`),
  matched faces keep the same plane, offsets and scale, and only the texture
  name changes, even when the size differs (`GENERIC93` 128 →
  `CIR_SNOW02` 256, `[ 1 0 0 -48 ] ... 0 1 1` unchanged). New names are
  written in UPPERCASE.
- Swaps are mostly **one old texture to one new texture**, but a single old
  texture is sometimes split across 2-3 replacements, depending on where it
  is used.
- `stalkyard2` and `snowyard` share no plane strings, so you can't diff them
  face by face. Compare texture *sets* instead (usage counts per map).
- Git history only gives about 160 usable old→new pairs. Most are
  cir→cir touch-ups. Useful ones include `generic93>cir_snow02`,
  `out_gravel>cir_rocks12`, `out_w6d/out_w6b>cir_wood07`,
  `c1a3wall01/10>cir_wall08`, `{gate>{cir_fence01`,
  `{rail1>{cir_window02`, `xcrate10a>cir_crate17`, `c2a5_dr>cir_outdoor01`
  and `c1a4i_w1b/tnnl_flr4/crete4_flr02>cir_mount03`.
- What training2 / snowyard kept: `sky`, `clip`, `origin`, `aaatrigger`,
  `black`, `{ladder*`, `lab1_trim3`, `lab1_stair*`, light textures,
  `subway_lights`, `+0recharge`/`rechargeedge1`, some crates and grey
  concrete (`crete4_flr0x`, `tnnl_flr*`).
- Every Cold Ice map uses a `cir*mont1` skybox (`cirdaymont1`,
  `cirnightmont1`, `cirduskmont1`, `cirsnowlake1`). The exception is
  latenightxmas, which uses `space`.

## 3. Derived ("re-tinted") textures: 1:1 Half-Life → Cold Ice

Several custom WADs hold blue/frosted versions of stock HL textures that keep
the same layout and size. These are the safest swaps. Found by
perceptual-hash matching of WAD contents (similarity > 0.85):

| WAD | Derived texture ← HL original |
|---|---|
| glacialcore | `cir_labw1/3/4/5/6/7/7b` ← `c1a0_labw*`, `cir_flr1` ← `c1a1_flr1`, `cir_flr2c`/`bir_flr2c` ← `c1a1_flr2c`, `cir_c1c` ← `c1a4_c1c`, `cir_ceil01` ← `c3a2_ceil`, `cir_ceil02` ← `babtech_ceil01`, `cir_bktb` ← `c1a1_bktb`, `cir_brd5` ← `lab3_brd5`, `cir_ca1x2b` ← `ca1x2b`, `cir_gdoor01` ← `lab1_door01`, `cir_elev1_dr/trim` ← `elev1_dr/trim`, `cir_introdr1a/b` ← `introdr1a`, `cir_labflrb/c` ← `c1a0_labflr*`, `cir_w2` ← `ca1x_w2`, `cir_generic015n` ← `generic015n`, `cir_generic95c` ← `generic95`, `cir_silo2b` ← `c1a4_silo2b`, `cirte4_flr02` ← `crete4_flr02`, `cir_drk_ceil*` ← `drkmtlt_ceil01*`, `cir_frostgrate` ← `frostgrate`, `cirlab1_w8flr1c/d` ← `lab1_w8flr1c/d`, `cir_pan3a` ← `c1a4_pan3a`, `bir_bordl9` ← `babtech_bordl9` |
| datafloe | `cir_pan1/2/2b` ← `c2a4_pan1/2`, `cir_pan3` ← `c2a4x_pan3`, `cir_h2e*` ← `c2a4x_h2e*`, `cir_gen95c` ← `generic95c`, `cir_c4d2` ← `lab1_c4d2`, `cir_brd3d` ← `lab1_brd3d`, `cir_1x2b` ← `ca1x2b`, `cir_dedge` ← `c1a1dooredge`, `cir_gen72` ← `generic72`, `cir_map1/2` ← `lab1_map1/2`, `cir_pow` ← `c1a4_pow`, `cir_w1b` ← `c2a4e_w1`, `cir_w8a` ← `lab3_w8a` |
| coldice | `cir_floor06` ← `tnnl_flr1b`, `cir_outdoor01` ← `c2a5_dr`, `cir_brick15` ← `crete3_flr05b`, `cir_wall06`/`cir_stone11` ← `c3a1_w5b`, `cir_wall12/13/14` ← `c2a4_h2e*/h2f`, `cir_crate31/32/34/35` ← `xcrate9*`, `cir_mount04` ← `out_rk3`, `cir_sign04/05` ← `sign18-25` |
| spacepirate | `snowsphinc` ← Xen sphincter (used 379x in bounce2), `crete_flr_snow`, `gnd_snow`, `helpad_snow` |

## 4. Pitfalls

- **Duplicate names across WADs resolve first-wins** in the `wads.cfg` order
  that `Compile-Map.psm1` writes (`coldice, datafloe, thetemple, glacialcore,
  latenightxmas, storm, decals, halflife, icerink, liquids, spacepirate,
  spraypaint, xeno`). `cir_w4`, `cir_labw8` and `cir_w8ceil1` exist in both
  datafloe and glacialcore with different art. datafloe wins, so
  glacialcore's `cir_w4` (128x144) can never be used: you get datafloe's
  160x128 white wall instead. Avoid those names, or check which copy wins.
- The map's `"wad"` key is ignored by the build (`-wadconfig all`); it only
  matters for opening the map in Hammer/J.A.C.K.
- The add-on WAD (`wads/<map>.wad`) is *not* in the compile WAD list. The
  reskin must resolve entirely from the base WADs.
- Light textures emit what `maps/lights.rad` says, not what they look like.
  For example, `~LIGHT5F` (a yellow texture) is overridden to teal 90 190 140
  for Training 2, and `~LIGHT5A` is the "Cold Ice" 200 200 255 light.
  Swapping a light texture changes the lighting, so pick replacements that
  have a rad entry.
- **Check for `info_texlights` in the map.** It overrides `lights.rad` per
  texture name. If you swap a light texture and leave its key alone, the new
  texture falls back to `lights.rad`. In frost_party v1 that made
  `+0~generic86b` 20000 instead of 1526, and `+0~tnnl_lgt3` blue
  150 150 210. Rename the keys to the new names and keep the values
  (`EntityEdits` with `newkey`).
- **Lamp colour also lives in entities, not just textures.** Yellow halos
  come from `env_sprite` glows (`sprites/glow03.spr`, `rendercolor` such as
  `241 165 11`), and the cast light comes from `light`/`light_spot`
  `_light` values. The texture swap alone leaves yellow lamps. Make the
  glows `241 241 241` (the map's existing white glows) and set the lights to
  `255 255 255 <brightness>`, keeping the brightness.
- **Masked/derived art carries its own background.** `snowsphinc` is a
  sphincter on *white snow*, whereas `c4a1a_sphinc1` sits on flesh. Ground
  under and around Xen props was `c2a5mound`, which the swap turns to
  snow. That is fine outdoors, but indoor rooms show a snow pad. After a
  Xen swap, look for mound/snow faces next to indoor floors and override
  them to the adjacent floor (copying its alignment).
- `+0`/`+a` toggled/animated textures need the whole family in the WAD.
  Only swap to another family that has the same frames
  (`+0~tnnl_lgt3`/`+a~tnnl_lgt3`, `+0~generic86b`/`+a~generic86b` exist).
- Keep the `!`/`{`/`+`/`~` prefix class when swapping (water, masked,
  animated, light).
- `workspace/maps/<addon>/` is a gitignored unpacked copy. Edit
  `workspace/add-ons/<addon>/maps/<addon>/<addon>.map` (submodule) and copy
  it over.

## 5. Tooling

- `powershell/Retexture-Map.ps1 -In <orig.map> -Out <map> -Swaps <csv>
  [-SkyName x] [-Wad "..."]`. CSV columns: `old,new,fit,group`.
  - `fit=0`: name-only swap, the rest of the face line stays byte-identical
    (the human method). Use it for natural tileables (rock, snow, water).
  - `fit=1`: rescales offsets and scale so the new texture covers the same
    world area. Use it for panels, crates and sphincters whose features must
    line up with the brush.
  - It reads texture sizes from the WADs in compile order, throws on unknown
    targets and warns on swaps that match nothing.
  - `-FaceOverrides <csv>` (`plane,texture,align`): retextures a single face,
    matched by its three-point plane string. Use it for one-off defects that a
    name swap can't fix (e.g. one indoor snow pad).
  - `-EntityEdits <csv>` (`classname,key,match,newkey,newvalue`; `match` may
    be `*`): changes entity values, or renames keys such as `info_texlights`
    entries.
  - `-AddEntities <file>`: appends raw entity blocks (snow, music).
  - Each feature reports hit counts and warns on edits that matched nothing.
- To find a defect from a screenshot, parse brushes (plane points work as a
  rough bbox for axial brushes; rotated/clipped plane points can lie far
  outside the brush). Search near distinctive props (here the sphincters)
  and compare the face textures at floor height against the neighbouring
  floors.

### Map features every Cold Ice map gets

- **Snow:** one point entity
  `{ "classname" "env_snow" "origin" "<inside the map>" }`.
  `CBasePlayer` (`player.cpp`, the `gmsgReceiveW` weather message) checks
  for `env_snow`/`func_snow` and the client draws the snow, so origin and
  keys don't matter beyond being in the map. `env_rain` gives rain instead.
- **Music:** `trigger_mp3audio` with `"message" "media/<track>.mp3"` and
  `"spawnflags" "1"` (loop). The gamerules fire it on each player's welcome
  (`multiplay_gamerules.cpp`), and `cl_` music settings decide whether it
  plays. `"health"` isn't read by the code; existing maps put a loose track
  number there.
- Tracks (`redist/media/`) and the maps that use them: 01-snowflakes
  (frostmill), 02-snowfall (training2, frozen_bunker), 03-frostfight
  (bounce2, frozenwarehouse), 04-gifts (canyon), 05-jubilee (chillworks,
  frosty, ice_pit), 06-serenity (coldice, frost_party), 07-catching-santa
  (catacombs, comet, furrow, suspension), 08-lamenting (doublefrost),
  09-whispers (depot, overflow, thechill), 10-another-one (cold_base,
  glacialcore, snow_camp, storm), 12-last-rites (drift, quadfrost),
  13-topsy-turvy (datafloe, fences, snowtransit), 14-honor-guard
  (defroster, focus, stalkyard2), 15-that-time-again (snowcross, themill),
  16-the-snowman (glupshitto, latenightxmas), gamestartup (frostfire,
  snowyard, training). Pick a track that suits the map's mood and is little
  used.
- Always run against the **original** map so iterations stay reproducible.
  For frost_party: `git -C add-ons show 3b519bc:frost_party/maps/frost_party/frost_party.map`.
- Validate with hlcsg + hlbsp using the `Select-Wad-List` cfg (see
  `Compile-Map.psm1`). Check the `.log` for missing textures and for
  "Using Wadfile ... Contains N used textures".
- To check a texture by eye, decode WAD3 miptex (lump type 0x43: name at
  +0, w/h at +16, offsets at +24, palette after the 4 mips + 2 bytes) and
  render contact sheets with System.Drawing under Windows PowerShell 5.1.
  pwsh 7 lacks the System.Drawing references for Add-Type.

## 6. frost_party reskin (v1, 2026-11-19)

Source: Xen outpost / floating islands with healing pools. Mostly Xen
organics, yellow c3a2b reactor panels, orange trrm panels and teal c1a0 lab
walls. Swaps: [`retexture/frost_party_swaps.csv`](retexture/frost_party_swaps.csv),
5918 of about 26k faces. Skybox `xen8` → `cirnightmont1`. `"wad"` key
rewritten from `pool_party.wad` to the workspace WADs.

| Group | Swaps | Rationale |
|---|---|---|
| Xen organics | `c4a1a_swmpwl`→`cir_rock11` (2126), `c4a1a_sphinc1/1b`→`snowsphinc` (fit), `c2a5mound`→`cir_snow02`, `c2a5mound2`→`cir_snow03`, `xeno_6b`→`cir_rock16` | bounce2 precedent (`snowsphinc`, `cir_rock11/15/16`, `cir_snow*`) |
| Liquid | `!fluid3`→`!cir_water01` | green slime → Cold Ice blue water (still `!` water) |
| Hot → blue | `c3a2b_reac5/reac1c/reac2e4/reac2c`, `trrm_pan5/pan2`→`cir_metal07`; `c3a2b_reac1`, `trrm_pan1`→`cir_wall19` (48-wide strips); `c3a2b_reac`→`cir_metal06`; `trrm_pan6`→`cir_pipe01`; `trrm_pan8`, `babtech_sildr2`→`cir_metal11` (fit); `trrm_pan4`→`cir_pan1` (fit) | yellow/orange panels → blue metals |
| Crates | `xcrate11b/d/e`→`cir_crate33/31/32` (fit), `xcrate12b`→`cir_crate17` (fit) | red crates → olive / wood crate sets |
| Lab re-tint | `c1a0_labw5/6/7b/7c`, `c1a1_flr1`, `c1a1_flr2c`, `c1a4_c1c`, `generic95c`, `lab1_c4d2`, `generic015n`, `crete4_flr02`, `c1a4_silo2b` → glacialcore/datafloe `cir_*` twins | same art re-tinted blue (§3) |
| Lights | `~light5f`→`~light5a`, `+0~tnnl_lgt4`→`+0~tnnl_lgt3`, `+0~generic86`→`+0~generic86b` | yellow/orange emitters → cold white-blue; `info_texlights` keys renamed in v2 so they still emit white |
| Hazard strips (v2) | `c2a3_gar3`, `c2a3_gar4` → `stripes4` | yellow/black → red/white |

Kept on purpose (conservative): neutral concretes and metals (`generic029`,
`c3a1_w5d`, `-0tnnl_w13a`, `c1a4tnnl1`, `crete4b1`, `tnnl_*`, `silo2_*`,
`c3a1_w2a/w5a`, `c3a2a_w1*`, `crete2_flr03a`), brown/beige earth tones
(`generic031`, `c1a1w1m`, `c1a1_trim2`, `c1a4i_w1a`, `con1_wall01p`,
`tnnl_w4a`, `c1a2_c1`), signs `c3a2sign*`,
chargers, the soda machine `generic88a/b`, `barrel3`, `c2a3_door`,
`~light3e` (already teal), `subway_lights`, `c1a0_labw2`, `c1a0_labw8`
(name collision), fifties consoles, grates, ladders and tool textures.

Validated: hlcsg/hlbsp compile, no missing textures. The brush/leaf warnings
were already in the source map. Not yet checked in game.

### Open questions (v1; see §7 for answers)

- ~~`cir_rock11` for the island undersides~~ approved.
- ~~`cir_metal07` too uniform?~~ approved.
- ~~Sky: `cirnightmont1` vs `space`~~ `cirnightmont1` approved.
- Do the pools still read as healing with blue water?
- Light colour shift: the `~light5f` areas went from teal to 200 200 255.
- Second pass: `generic031` (brown trim, 978 faces), `generic029`, `c3a1_w5d`
  and the `c3a2sign45/46` PORT signs.

## 7. Feedback log

Add one entry per test round: what looked wrong, what changed in the CSV.

Full rebuild command for frost_party (run from `workspace/`):

```powershell
git -C add-ons show 3b519bc:frost_party/maps/frost_party/frost_party.map > $env:TEMP\fp.map
pwsh .\powershell\Retexture-Map.ps1 -In $env:TEMP\fp.map -Out add-ons\frost_party\maps\frost_party\frost_party.map `
  -Swaps .\ai\retexture\frost_party_swaps.csv -SkyName cirnightmont1 `
  -Wad '\workspace\wads\coldice.wad;\workspace\wads\halflife.wad;\workspace\wads\xeno.wad;\workspace\wads\liquids.wad;\workspace\wads\decals.wad;\workspace\wads\glacialcore.wad;\workspace\wads\datafloe.wad;\workspace\wads\spacepirate.wad' `
  -FaceOverrides .\ai\retexture\frost_party_faces.csv -EntityEdits .\ai\retexture\frost_party_entities.csv `
  -AddEntities .\ai\retexture\frost_party_add.ent
Copy-Item add-ons\frost_party\maps\frost_party\frost_party.map maps\frost_party\ -Force
```

### Round 1 (2026-11-19)

Approved: `cir_rock11` (island rock), `cir_metal07` (reactor shell),
`cirnightmont1` sky.

Fixed in v2:
- **Yellow outdoor lamps → white.** 19 `env_sprite` glows
  (`241 165 11`/`241 176 72` → `241 241 241`), 7 `light` entities
  (`243 142 40`, `255 173 8` → `255 255 255`, brightness kept), and
  `info_texlights` keys renamed to the swapped light textures (white values
  kept). The lamp face texture `+0~tnnl_lgt3` was already white.
- **Yellow/black hazard strips → red/white:** `c2a3_gar3`, `c2a3_gar4` →
  `stripes4` (halflife.wad, 32x32). A 1:1 swap keeps about the same stripe
  density.
- **Snow pad in the room at (524,-784,-800)** (brush top that was
  `c2a5mound`) → `out_pav3` with the adjacent floor's alignment
  (`frost_party_faces.csv`).
- **Added** `env_snow` and `trigger_mp3audio` `06-serenity` (calm track for
  the "relaxing healing pools" theme, only otherwise used by coldice)
  (`frost_party_add.ent`).

Still open:
- The lamp housings are `cir_crate17` (wood), swapped from `xcrate12b`.
  A grey metal such as `cir_metal05` might suit them better.
- The small `CIR_SNOW03` mound in the same room (line ~42097, ent 535) is
  still snow.
- The yellow `c3a2sign45/46` PORT signs and the yellow block in screen 2
  are unchanged.
