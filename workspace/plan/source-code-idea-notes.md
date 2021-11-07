## Interesting Items

1. dlls/player.cpp
    1. EnableControl(BOOL fControl) - for freeze
    1. impulse 104 to dump globals
    1. m_bloodColor
1. dlls/weapons.cpp
    1. `UTIL_BloodDrips` -> 
1. dlls/satchel.cpp
    1. #ifndef `CLIENT_DLL` else `LoadVModel`
1. dlls/util.h
    1. The use of `ASSERT` for debugging
1. dlls/scientist.cpp
    1. 1291:
```c++
if (yaxw > 180) yaw -= 360;
if (yaw < -180) yaw += 360;

if (yaw > 0)
    pev->sequence = m_baseSequence + SITTING_ANIM_sitlookleft;
else
    pev->sequence = m_baseSequence + SITTING_ANIM_sitlookright;
```
1. dlls/tentacle.cpp
    1. 319: `PRECACHE_SOUND_ARRAY`
1. dlls/triggers.cpp
    1. 84: `pOther->pev->friction`
    1. 715: `CLIENT_COMMAND`

## Gestalt

1. Server/client messaging architecture
1. String capture for entities
1. Saverestore system
1. KeyValue
