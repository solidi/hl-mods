# Radar HUD Element

A client-side minimap, compass bar, and indicator system that tracks players and special entities. Renders a top-left radar panel with colored dots, a horizontal compass bar with cardinal directions, in-world overhead indicators for visible targets, and U-shaped behind indicators for off-screen targets.

## Features

- 128×128 px translucent radar panel in the top-left corner with colored dots
- Horizontal compass bar (top-center) showing cardinal directions and target markers within a 120° FOV
- Behind indicators that track targets outside the compass FOV along a U-shaped screen-edge path
- In-world overhead triangle indicators for nearby visible objective targets
- Distance text in feet displayed alongside all indicators
- Pulse animation on indicators for visibility
- Server-sent special entity tracking via `SpecEnt` network message for persistent map objects
- PVS-based entity scanning for players and dynamic world entities via `fuser4`
- Per-game-mode filtering and color mapping
- Disabled by `cl_radar 0`, `MUTATOR_NORADAR`, spectator mode, death, intermission, scoreboard, weapon menu, or singleplayer

## Client-Side Architecture

### Class: `CHudRadar` (in `src/cl_dll/hud.h`, ~line 695)

```cpp
class CHudRadar : public CHudBase
{
public:
    int Init(void);
    int VidInit(void);
    int Draw(float flTime);
    void ProcessPlayerState(void);
    void DrawBehindIndicator(float angle, float distance, int special);
    void DrawInWorldIndicator(Vector worldOrigin, float distance, int special);
    void DrawCompass(void);
    int MsgFunc_SpecEnt(const char *pszName, int iSize, void *pbuf);

private:
    int radar_height, radar_width;
    RADAR m_RadarInfo[MAX_RADAR_DOTS];                     // 64 slots for PVS entities
    SPECIAL_ENTITY_INFO m_SpecialEntities[MAX_SPECIAL_ENTITIES]; // 8 slots for server-sent entities
};
```

Instance: `gHUD.m_Radar`

### Supporting Structs

```cpp
typedef struct {
    Vector origin;
    float angle, distance, height;
    int special;
} RADAR;

typedef struct {
    Vector origin;
    int special_type;
    float last_update;
    bool active;
} SPECIAL_ENTITY_INFO;
```

### Static Helpers (in `radar.cpp`)

- `GetRadarColor(int special, int &r, int &g, int &b)` — Maps `RADAR_` type to RGB color
- `NormalizeAngle180(float angle)` — Wraps angle to [-180, 180] range

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `MAX_RADAR_DOTS` | 64 | Max PVS-tracked entities (defined in `hud.h`) |
| `MAX_SPECIAL_ENTITIES` | 8 | Max server-sent entity slots (defined in `hud.h`) |
| `MAX_DISTANCE` | 1000 | Max radar tracking distance (game units) |
| `PI_180` | π/180 | Degrees-to-radians conversion |

## Radar Types (`fuser4` / special values)

Defined in `src/common/const.h` (lines 976–993). Set on entities via `pev->fuser4` server-side and transmitted to clients through `state->fuser4` in `client.cpp`.

| Value | Constant | Color | Dot Size | Used By |
|-------|----------|-------|----------|---------|
| 0 | `RADAR_TEAM_BLUE` | Blue (0,160,240) | Normal | Teamplay (blue team players) |
| 1 | `RADAR_TEAM_RED` | Red (240,0,0) | Normal | Teamplay (red team players) |
| 2 | `RADAR_TEAM_YELLOW` | Yellow (240,240,0) | Normal | Teamplay (yellow team players) |
| 3 | `RADAR_TEAM_GREEN` | Green (0,240,0) | Normal | Teamplay (green team players) |
| 4 | `RADAR_VIRUS` | Red (240,0,0) | 2x | Chilldemic (skeleton/virus team) |
| 5 | `RADAR_COLD_SPOT` | Green (0,240,0) | 2x | Cold Spot, LMS (objective point) |
| 6 | `RADAR_CHUMTOAD` | Green (0,240,0) | 2x | CTC (chumtoad holder), chumtoad NPC |
| 7 | `RADAR_BUSTER` | Red (240,0,0) | 2x | Busters (buster player) |
| 8 | `RADAR_HORDE` | Red (240,0,0) | 2x | Horde (spawned monsters) |
| 9 | `RADAR_JESUS` | Blue (0,0,240) | 2x | JVS (armored man / "Jesus") |
| 10 | `RADAR_FLAG_BLUE` | Blue (0,0,240) | 2x | CTF (blue flag entity) |
| 11 | `RADAR_FLAG_RED` | Red (240,0,0) | 2x | CTF (red flag entity) |
| 12 | `RADAR_BASE_BLUE` | Blue (0,0,240) | N/A | CTF/Loot/KTS (blue base, in-world only) |
| 13 | `RADAR_BASE_RED` | Red (240,0,0) | N/A | CTF/Loot/KTS (red base, in-world only) |
| 14 | `RADAR_ARENA_RED` | Red (240,0,0) | Normal | Arena (red combatant) |
| 15 | `RADAR_ARENA_BLUE` | Blue (0,0,240) | Normal | Arena (blue combatant) |
| 16 | `RADAR_LOOT` | Orange (255,117,24) | 2x | Loot (loot item or carrier) |
| 17 | `RADAR_SNOWBALL` | White (255,255,255) | 2x | KTS (snowball entity) |

**Notes:**
- Values 0–3 are team identifiers and render at normal dot size
- Values ≥ `RADAR_COLD_SPOT` (5) are "special" entities eligible for compass markers and behind indicators
- Local player dot is always gray (200,200,200)
- Default non-special players render in blue (`RGB_BLUEISH`)
- In `GAME_ICEMAN` mode, non-special player dots are 2× size

## Two Data Sources

### 1. PVS-Based Entity Scanning (`ProcessPlayerState`)

Every frame, `ProcessPlayerState` iterates all engine entities (`gEngfuncs.GetEntityByIndex`, indices 1 to `MAX_EDICTS`) and builds the `m_RadarInfo[]` array:

- Skips entities without models, entities marked `EF_NODRAW`, entities with stale `messagenum`
- Non-player world entities are only included if they have a non-zero `fuser4`
- Dead players (health ≤ 0) are excluded
- **PropHunt filter:** Skips non-local prop entities (`fuser4 > 0`)
- **CTF filter:** Skips flag entities (`RADAR_FLAG_BLUE` / `RADAR_FLAG_RED`) — these are tracked via `SpecEnt` instead
- Calculates: relative angle (`view_angle - entity_angle`), distance (capped at `MAX_DISTANCE`), height difference (normalized by 72)
- Stores world origin raised by 70% of entity bbox height for in-world indicator placement
- Result count stored in `gHUD.m_PlayersInRadar`

### 2. Server-Sent Special Entities (`SpecEnt` message)

Permanent or semi-permanent map objects (bases, cold spots, goal entities) are sent from the server via the `gmsgSpecialEntity` network message. These are stored in `m_SpecialEntities[]` (8 slots) and persist across frames regardless of PVS visibility.

## Server-Side Registration & Message Format

### Registration (in `src/dlls/player.cpp`):
```cpp
gmsgSpecialEntity = REG_USER_MSG("SpecEnt", -1);
```

### Sending (active entity):
```cpp
MESSAGE_BEGIN(MSG_ALL, gmsgSpecialEntity);
    WRITE_BYTE(slotIndex);  // Slot 0-7
    WRITE_BYTE(1);           // Active
    WRITE_COORD(origin.x);
    WRITE_COORD(origin.y);
    WRITE_COORD(origin.z);
    WRITE_BYTE(RADAR_TYPE);  // RADAR_ constant
MESSAGE_END();
```

### Sending (deactivate slot):
```cpp
MESSAGE_BEGIN(MSG_ALL, gmsgSpecialEntity);
    WRITE_BYTE(slotIndex);  // Slot 0-7
    WRITE_BYTE(0);           // Inactive
MESSAGE_END();
```

### Message Format
| Field | Type | Description |
|-------|------|-------------|
| Index | `WRITE_BYTE` | Slot index (0–7) |
| Active | `WRITE_BYTE` | 1 = active, 0 = inactive |
| Origin X | `WRITE_COORD` | World X (only if active) |
| Origin Y | `WRITE_COORD` | World Y (only if active) |
| Origin Z | `WRITE_COORD` | World Z (only if active) |
| Type | `WRITE_BYTE` | `RADAR_` constant (only if active) |

### Game Modes Using `SpecEnt`

| Game Mode | File | Slot Usage | Type | Purpose |
|-----------|------|------------|------|---------|
| Cold Spot | `coldspot_gamerules.cpp` | Slot 0 | `RADAR_COLD_SPOT` | Objective point location |
| CTF | `ctf_gamerules.cpp` | Slot per base (team index) | `RADAR_BASE_RED` / `RADAR_BASE_BLUE` | Flag base positions |
| KTS | `kts_gamerules.cpp` | Slots for goals | `RADAR_BASE_RED` / `RADAR_BASE_BLUE` | Snowball goal positions |
| LMS | `lms_gamerules.cpp` | Slot 0 | `RADAR_COLD_SPOT` | Safe spot location |
| Loot | `loot_gamerules.cpp` | Slot 0 | `RADAR_BASE_RED` | Goal entity position |

All modes clear unused slots by sending inactive messages for remaining indices (1–7 typically).

## Visual Rendering

### 1. Radar Panel (minimap)

- **Position:** Top-left corner, at `(0, 16)`
- **Size:** 128×128 pixels
- **Background:** HUD-colored fill at alpha 10
- **Center:** Local player's position
- **Dots:** Colored rectangles positioned by angle/distance from center
  - Base size: 5 px, modified by height difference (2 px min, 8 px max)
  - Alpha: 160 base, adjusted by height (100–200 range)
  - Height < 0 (below): smaller dot, dimmer
  - Height > 0 (above): larger dot, brighter
  - Special entities (≥ `RADAR_COLD_SPOT`) rendered at 2× size
  - Local player: gray (200,200,200)

### 2. Compass Bar (`DrawCompass`)

A horizontal compass bar centered near the top of the screen, showing cardinal directions and target markers. **Controlled by `cl_compass` cvar.**

- **Position:** Centered horizontally, `COMPASS_Y_OFFSET` from top (YRES(36))
- **Width:** 50% of screen width (`COMPASS_BAR_WIDTH_FRAC`)
- **FOV:** 120° visible angular range (`COMPASS_FOV`)
- **Elements:**
  - Horizontal line (1 px thick, alpha 140)
  - Tick marks every 15° above the line (small ticks YRES(4), cardinal ticks YRES(6))
  - Cardinal letters (N/E/S/W) drawn above their ticks at alpha 180
  - Target triangles (XRES(6) × YRES(6)) drawn below the line for each PVS entity within FOV, colored by type, at alpha 200
  - Distance text in feet below each target triangle (shown when > 12 ft)
- **Angle mapping:** Uses `m_RadarInfo[].angle` (already view-relative) normalized to [-180, 180], mapped to pixel offset via `pixelsPerDegree = barWidth / COMPASS_FOV`
- **Note:** Currently shows ALL PVS entities on the compass (the special-only filter is commented out)

#### Compass Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `COMPASS_FOV` | 120.0 | Visible angular range (degrees) |
| `COMPASS_HALF_FOV` | 60.0 | Half the FOV |
| `COMPASS_BAR_WIDTH_FRAC` | 0.5 | Fraction of ScreenWidth |
| `COMPASS_Y_OFFSET` | YRES(36) | Top margin |
| `COMPASS_LINE_THICKNESS` | 1 | Horizontal line height |
| `COMPASS_TICK_HEIGHT` | YRES(4) | Small tick height |
| `COMPASS_CARDINAL_TICK_HEIGHT` | YRES(6) | Cardinal tick height |
| `COMPASS_TICK_SPACING` | 15.0 | Degrees between ticks |
| `COMPASS_TARGET_TRI_WIDTH` | XRES(6) | Target triangle width |
| `COMPASS_TARGET_TRI_HEIGHT` | YRES(6) | Target triangle height |
| `COMPASS_LINE_ALPHA` | 140 | Line/tick alpha |
| `COMPASS_CARDINAL_ALPHA` | 180 | Cardinal letter alpha |

### 3. Behind Indicators (`DrawBehindIndicator`)

Triangular arrows that appear along screen edges for targets **outside the compass FOV** (behind the player). They follow a smooth U-shaped path around the bottom of the screen. **Only active when `cl_compass` is enabled.**

- **Trigger:** Special entities with `special >= RADAR_COLD_SPOT` (5) that are outside the compass's 120° FOV and within ~28 ft (`BEHIND_INDICATOR_MAX_DISTANCE = 448 game units`)
- **Parameters:** `(float angle, float distance, int special)` — angle is view-relative
- **Gating:** `fabs(NormalizeAngle180(angle)) > COMPASS_HALF_FOV` AND `distance <= 448`
- **Side detection:** `normalizedAngle < 0` = target is to the left; `normalizedAngle > 0` = target is to the right

#### U-Shaped Path

The behind arc (60°–180° on each side) is mapped to `behindFrac` (0.0 at compass edge → 1.0 at directly behind):

- **Phase 1 — Side edge** (`behindFrac` 0.0–0.5): Arrow appears on the left or right screen edge at mid-height and slides **down** toward the bottom corner. Arrow is a horizontal triangle with tip pointing toward the screen edge (outward) and base inward.
- **Phase 2 — Bottom edge** (`behindFrac` 0.5–1.0): Arrow slides along the **bottom edge** from the corner toward screen center. Arrow is a downward-pointing triangle with tip near the bottom margin.

#### Arrow Drawing

- **Side arrows:** Tip at margin, widening inward. Drawn as horizontal filled scanlines. Left arrow: tip at `x = margin`, grows rightward. Right arrow: tip at `x = ScreenWidth - margin`, grows leftward.
- **Bottom arrows:** Downward-pointing triangle, base at `ScreenHeight - margin - triH`, tip at `ScreenHeight - margin`. Drawn as horizontal scanlines narrowing downward.
- **Size:** `BEHIND_INDICATOR_SIZE_WIDTH` (XRES(20)) × `BEHIND_INDICATOR_SIZE_HEIGHT` (YRES(20))

#### Alpha & Pulse

- Alpha: Linear interpolation from 255 (close) to 100 (at max distance)
- Pulse: `sin(time * 3.5) * 0.3 + 0.7` multiplied into alpha
- Distance text in feet drawn inward from side arrows, or above bottom arrows

#### Behind Indicator Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `BEHIND_INDICATOR_MAX_DISTANCE` | 448.0 | Max distance in game units (~28 ft) |
| `BEHIND_INDICATOR_SCREEN_MARGIN` | 20 | Pixel margin from screen edge |
| `BEHIND_INDICATOR_SIZE_WIDTH` | XRES(20) | Arrow width |
| `BEHIND_INDICATOR_SIZE_HEIGHT` | YRES(20) | Arrow height |
| `BEHIND_INDICATOR_PULSE_FREQUENCY` | 3.5 | Pulse speed in Hz |
| `BEHIND_INDICATOR_PULSE_AMPLITUDE` | 0.3 | Pulse amplitude |
| `BEHIND_INDICATOR_PULSE_OFFSET` | 0.7 | Pulse baseline |
| `BEHIND_INDICATOR_ALPHA_MIN` | 100 | Minimum alpha |
| `BEHIND_INDICATOR_ALPHA_MAX` | 255 | Maximum alpha |

### 4. In-World Indicators (`DrawInWorldIndicator`)

Overhead triangles rendered in screen-space above nearby visible targets.

- **Trigger:** `RADAR_COLD_SPOT`, `RADAR_BASE_RED`, `RADAR_BASE_BLUE` (from SpecEnt slots), and `RADAR_HORDE` or same-team entities (from PVS). These are always drawn regardless of `cl_compass`.
- **Disabled in:** FFA, Gun Game, Snowball Fight, Instagib, Cold Skull (solo/non-objective modes)
- **Position:** 24 units above entity origin, projected to screen via `WorldToScreen`
- **Shape:** Downward-pointing filled triangle (XRES(10) × YRES(8))
- **Colors:** Same `GetRadarColor` mapping
- **Alpha:** `255 - (distance / 2000) * 155`, clamped to [100, 255], with pulse (3.5 Hz)
- **Distance text:** In feet, drawn below the triangle tip when > 12 ft
- **Visibility:** Only drawn when target is in front of the camera and within screen bounds (20 px margin)
- **Unit conversion:** `game_units * 0.01904 * 3.28084 = feet`

## Draw Loop Flow (`Draw`)

1. **Visibility checks:** `cl_radar`, spectator (`g_iUser1`), health ≤ 0, intermission, max clients == 1, scoreboard, weapon menu, `MUTATOR_NORADAR`
2. **`ProcessPlayerState()`** — Scan PVS entities, build `m_RadarInfo[]`
3. **Compass bar** — If `cl_compass` is enabled, draw `DrawCompass()`
4. **Radar panel** — Draw 128×128 background, iterate `m_RadarInfo[]` for colored dots
5. **PVS indicator loop** — For each non-local entity in `m_RadarInfo[]`:
   - Skip `RADAR_COLD_SPOT`, `RADAR_BASE_RED`, `RADAR_BASE_BLUE` (handled by SpecEnt loop)
   - `RADAR_HORDE` or same-team (`localPlayer->fuser4 == special`): → `DrawInWorldIndicator` (always)
   - If `cl_compass` is OFF: skip remaining indicators
   - Non-special or team players (< `RADAR_COLD_SPOT`): skip
   - Everything else: → `DrawBehindIndicator`
6. **SpecEnt indicator loop** — For each active `m_SpecialEntities[]` slot:
   - Calculate distance and angle from local player
   - `RADAR_COLD_SPOT`, `RADAR_BASE_RED`, `RADAR_BASE_BLUE`: → `DrawInWorldIndicator` (always)
   - If `cl_compass` is OFF: skip remaining indicators
   - Everything else: calculate view-relative angle → `DrawBehindIndicator`

### Compass ↔ Behind Indicator Relationship

The compass and behind indicators are complementary:
- **Compass** shows targets within the front 120° FOV (±60° from view center)
- **Behind indicators** show targets in the remaining 240° arc (±60° to ±180°)
- Both are gated on `cl_compass` — disabling the compass also disables behind indicators
- In-world indicators (`DrawInWorldIndicator`) are independent and always active when the radar is on

## Configuration

### Client CVars

| CVar | Default | Flags | Defined In | Description |
|------|---------|-------|------------|-------------|
| `cl_radar` | `1` | `FCVAR_ARCHIVE` | `src/cl_dll/hud.cpp` | Enable/disable entire radar HUD |
| `cl_compass` | `1` | `FCVAR_ARCHIVE` | `src/cl_dll/hud.cpp` | Enable/disable compass bar + behind indicators |
| `Radar.debug` | `0` | — | `radar.cpp` (`_DEBUG` only) | Debug console output |

Both cvars are declared as `extern cvar_t*` in `radar.cpp` and defined/created in `hud.cpp`.

## Integration Notes

- Class definition: `src/cl_dll/hud.h` (CHudRadar, ~line 695)
- Implementation: `src/cl_dll/radar.cpp` (~773 lines)
- Instance: `gHUD.m_Radar`
- Player count stored in: `gHUD.m_PlayersInRadar`
- Radar type constants: `src/common/const.h` (lines 976–993)
- Server message registered in: `src/dlls/player.cpp` (`gmsgSpecialEntity` → `"SpecEnt"`)
- Entity state transmission: `src/dlls/client.cpp` (`state->fuser4 = ent->v.fuser4`)
- CVars defined in: `src/cl_dll/hud.cpp` (~line 68 declarations, ~line 611–612 `CVAR_CREATE`)
- Objective HUD offsets x-position by 130 px when radar is enabled
- Build: MSVC 2019, `hl_cdll.vcxproj`, Release/Win32

## Known Issues

- **`fuser4` overloading:** The same field is used for both radar type identification and game-mode-specific logic (e.g., PropHunt uses it as a prop model index). Can cause unintended radar dots in modes that assign non-radar meanings to `fuser4`.
- **CTF flag filtering:** CTF flags are explicitly filtered from PVS scanning but are still set with `fuser4 = RADAR_FLAG_RED/BLUE`, suggesting they were intentionally removed from the minimap while retaining indicator support via SpecEnt.
- **Self-index assumption:** The local player self-detection `(gEngfuncs.GetLocalPlayer()->index - 1) == index` assumes the entity index maps directly to the `m_RadarInfo` array index. This holds because entities are scanned sequentially from index 1, but skipped entities do shift the mapping — the `index` variable is the m_RadarInfo slot, not the entity index.
- **Compass shows all entities:** The special-only filter in `DrawCompass` is currently commented out, so all PVS entities appear on the compass bar (including regular players and team members).
- **SpecEnt stale data:** Server-sent entity data never expires on the client. If the server stops sending updates, stale entries persist indefinitely. The `last_update` field is tracked but unused.

## Testing

```
// Client console commands:
cl_radar 0          // Disable entire radar
cl_radar 1          // Enable radar
cl_compass 0        // Disable compass + behind indicators (radar panel + in-world still work)
cl_compass 1        // Enable compass + behind indicators
Radar.debug 1       // Debug output (DEBUG builds only)
```

```cpp
// Server-side: Add a test special entity
MESSAGE_BEGIN(MSG_ALL, gmsgSpecialEntity);
    WRITE_BYTE(0);           // Slot 0
    WRITE_BYTE(1);           // Active
    WRITE_COORD(100.0f);     // X
    WRITE_COORD(200.0f);     // Y
    WRITE_COORD(0.0f);       // Z
    WRITE_BYTE(RADAR_LOOT);  // Type
MESSAGE_END();

// Server-side: Deactivate slot
MESSAGE_BEGIN(MSG_ALL, gmsgSpecialEntity);
    WRITE_BYTE(0);           // Slot 0
    WRITE_BYTE(0);           // Inactive
MESSAGE_END();
```

The radar renders during the HUD draw phase. All PVS-based tracking updates every frame via `ProcessPlayerState()`. Server-sent entities persist until explicitly deactivated.
