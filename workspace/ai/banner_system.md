# Banner HUD Element

A customizable banner system that displays team information and round start messages to players.

## Features

- Full-width horizontal banner (1/8 screen height)
- Positioned in upper quarter of screen with 15% opacity HUD-colored background
- Title text (HUD color, centered)
- Subtitle text (gray 180,180,180, 85% alpha)
- Configurable duration with fade out effect
- Triggered from server-side game rules via `gmsgBanner` network message

## Server-Side Usage

The banner is sent from server game rules code to clients via a registered user message.

### Registration (already done in `player.cpp`):
```cpp
extern int gmsgBanner;
// Registered in LinkUserMessages():
gmsgBanner = REG_USER_MSG("Banner", -1);
```

### Sending to a specific player (MSG_ONE):
```cpp
MESSAGE_BEGIN(MSG_ONE, gmsgBanner, NULL, pPlayer->edict());
    WRITE_STRING("You Are on Team Smelters");       // Title
    WRITE_STRING("Do you smell what I smell?");     // Subtitle
    WRITE_BYTE(80);                                  // Duration in tenths of second (80 = 8.0s)
MESSAGE_END();
```

### Broadcasting to all players (MSG_BROADCAST):
```cpp
MESSAGE_BEGIN(MSG_BROADCAST, gmsgBanner);
    WRITE_STRING("Player1 Vs. Player2");            // Title
    WRITE_STRING("The fight has begun!");            // Subtitle
    WRITE_BYTE(80);                                  // Duration in tenths of second
MESSAGE_END();
```

### Message Format
| Field | Type | Description |
|-------|------|-------------|
| Title | `WRITE_STRING` | Main heading text |
| Subtitle | `WRITE_STRING` | Descriptive text below title |
| Duration | `WRITE_BYTE` | Display time in tenths of a second (e.g. 80 = 8.0s) |

## Client-Side API

`ShowBanner` can also be called directly from client code, though currently all invocations come from server messages:

```cpp
gHUD.m_Banner.ShowBanner("Title Text", "Subtitle text", 8.0f);
```

Parameters:
- `title` - Main text (char[128] max)
- `subtitle` - Descriptive text below title (char[256] max)
- `duration` - How long to show the banner in seconds

## Visual Specifications

- **Background**: Full screen width, 1/8 screen height, HUD color at 15% alpha
- **Position**: Upper quarter of screen (`bannerY = (ScreenHeight - bannerHeight) / 4`)
- **Title**: HUD color, centered horizontally, drawn with console font (`DrawConsoleString`)
- **Subtitle**: Light gray (180,180,180), 85% alpha, centered, 24px below title, drawn with `DrawHudString`
- **Animation**: 
  - Fade out: 0.5 seconds before end of duration
  - Fade in: intended 0.3 seconds but non-functional (see Known Issues)

## Known Issues

- **Fade-in doesn't work**: The `Draw()` method calculates `totalDuration` as `2 * timeRemaining` each frame (since no start time is stored), so the fade-in branch only triggers in the last 0.3s — overlapping with fade-out and producing incorrect alpha values. A `m_flStartTime` member would be needed to fix this.
- **`textAlpha` unused**: The variable `float textAlpha = alpha / 255.0f;` is computed in `Draw()` but never applied. Title and subtitle are drawn at full text brightness regardless of fade state. Only the background rectangle actually fades.

## Game Modes Using Banners

The banner is used extensively across game modes (all in `src/dlls/`):

| Game Mode | File | Message Type | Purpose |
|-----------|------|-------------|---------|
| Arena | `arena_gamerules.cpp` | `MSG_BROADCAST` | Player matchup announcement |
| Busters | `busters_gamerules.cpp` | `MSG_ONE` | Team assignment |
| Chilldemic | `chilldemic_gamerules.cpp` | `MSG_ONE` | Team/role notification |
| Cold Skull | `coldskull_gamerules.cpp` | `MSG_ONE` | Mode info |
| Cold Spot | `coldspot_gamerules.cpp` | `MSG_ONE` | Mode info |
| CTC | `ctc_gamerules.cpp` | `MSG_ONE` | Mode info |
| CTF | `ctf_gamerules.cpp` | `MSG_ONE` | Mode info |
| Gun Game | `gungame_gamerules.cpp` | `MSG_ONE` | Mode info |
| Horde | `horde_gamerules.cpp` | `MSG_ONE` | Mode info |
| Instagib | `instagib_gamerules.cpp` | `MSG_ONE` | Mode info |
| JVS | `jvs_gamerules.cpp` | `MSG_ONE` | Role assignment |
| KTS | `kts_gamerules.cpp` | `MSG_ONE` | Team assignment |
| LMS | `lms_gamerules.cpp` | `MSG_ONE` | Mode info |
| Loot | `loot_gamerules.cpp` | `MSG_ONE` | Mode info / events |
| Multiplayer | `multiplay_gamerules.cpp` | `MSG_ONE` | Snowball Fight mode |
| Prop Hunt | `prophunt_gamerules.cpp` | `MSG_ONE` | Team assignment |
| Shidden | `shidden_gamerules.cpp` | `MSG_ONE` | Team assignment (Dealters/Smelters) |

The common pattern is to check `pPlayer->m_iShowGameModeMessage` timing before sending, and reset it to `-1` after sending. All modes currently use `WRITE_BYTE(80)` (8.0 seconds).

## Integration Notes

- Class definition: `src/cl_dll/hud.h` (CHudBanner, ~line 756)
- Implementation: `src/cl_dll/banner.cpp`
- Instance: `gHUD.m_Banner` (hud.h ~line 946)
- Initialized in: `src/cl_dll/hud.cpp` via `m_Banner.Init()`
- Server message registered in: `src/dlls/player.cpp` (`gmsgBanner`)
- Added to project: `src/projects/vs2019/hl_cdll.vcxproj`

## Testing

To test the banner, send a server message from any game rule's think function, or add a temporary direct call in client code:

```cpp
// Client-side test
gHUD.m_Banner.ShowBanner("Test Banner", "This is a test subtitle", 8.0f);

// Server-side test (in any player-context function)
MESSAGE_BEGIN(MSG_ONE, gmsgBanner, NULL, pPlayer->edict());
    WRITE_STRING("Test Banner");
    WRITE_STRING("This is a test subtitle");
    WRITE_BYTE(80);
MESSAGE_END();
```

The banner will render during the HUD draw phase and automatically handle timing, fading, and cleanup.
