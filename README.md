# Auto Headlights

A Cyberpunk 2077 redscript mod that switches vehicle headlights on and off based on ambient light.

## Features

- **Night:** lights on between configurable in-game hours (default 19:00 to 06:00).
- **Bad weather:** rain, fog, pollution, sandstorms and heavy clouds count as dark.
- **Tunnels and cover:** detects roofs, garages and overpasses, with its own delay so short overpasses don't flicker the lights.
- **Motorcycles:** headlight stays on whenever the engine is running (can be turned off in settings).
- **Low beams only:** high beams are left alone if you turn them on yourself.
- **Manual override:** using your headlight key pauses auto mode for the rest of the drive.
- **Pause / resume key:** configurable key, with an optional Shift, Ctrl or Alt modifier.
- **Mod Settings menu:** every option can be changed in game.
- **Standalone:** works on its own or alongside Vehicle Systems Simulation (VSS), and overrides VSS's force-on-at-entry behaviour without modifying it.

## Requirements

- [redscript](https://www.nexusmods.com/cyberpunk2077/mods/1511)
- [RED4ext](https://www.nexusmods.com/cyberpunk2077/mods/2380)
- [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780)
- [Mod Settings](https://www.nexusmods.com/cyberpunk2077/mods/4885)

## Installation

Copy the `r6` folder into your Cyberpunk 2077 install folder, so the script ends up at:

```
Cyberpunk 2077\r6\scripts\AutoHeadlights\AutoHeadlights.reds
```

## Settings

In game: **Settings → Mods → Auto Headlights**.

| Category | Setting | Default |
|---|---|---|
| General | Enable auto headlights | On |
| General | Pause / resume key | J |
| General | Pause / resume modifier | None |
| General | Headlight key pauses auto mode | On |
| General | Show notifications | On |
| General | Motorcycle headlights always on | On |
| Darkness detection | Lights on from (hour) | 19 |
| Darkness detection | Lights off from (hour) | 6 |
| Darkness detection | Bad weather turns lights on | On |
| Darkness detection | Tunnels turn lights on | On |
| Darkness detection | Tunnel ceiling height (m) | 10 |
| Timing | Night / weather delay (s) | 1.0 |
| Timing | Tunnel delay (s) | 3.0 |
| Timing | Lights off delay (s) | 4.0 |

## Notes

- Other headlight mods may conflict.

## License

Released under the [MIT License](LICENSE). You are free to use, modify and redistribute this code, including in your own mods, as long as the copyright notice is kept.
