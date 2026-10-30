# Auto Headlights

A Cyberpunk 2077 redscript mod that switches vehicle headlights on and off based on ambient light.

## Features

- **Night:** lights on between configurable in-game hours (default 19:00 to 06:00).
- **Bad weather:** rain, fog, pollution, sandstorms and heavy clouds count as dark. Nova City 2's darker weather (drizzle, downpour, storms, mist, gloomy, blackout and meme clouds) counts too.
- **Tunnels and cover:** detects roofs, garages and overpasses, with its own delay so short overpasses don't flicker the lights.
- **Adjustable ceiling height:** set how far above the vehicle a roof still counts as cover (default 10 m), so high overpasses and elevated highways don't trigger the lights.
- **Traffic (optional, off by default):** NPC vehicles can follow the same rules: lights for night, bad weather and tunnels, off in daylight. Tunnels are checked for traffic near you. Leave it off if another mod already handles traffic headlights.
- **Motorcycles:** headlight stays on whenever the engine is running, day or night (can be turned off in settings).
- **Low beams only:** high beams are left alone if you turn them on yourself.
- **Manual override:** using your headlight key pauses auto mode for the rest of the drive.
- **Pause / resume key:** configurable key, with an optional Shift, Ctrl or Alt modifier.
- **Mod Settings menu:** every option can be changed in game. Optional: without Mod Settings the defaults below apply.
- **Translatable:** on-screen messages go through Codeware's localization system.
- **Standalone:** works on its own or alongside Vehicle Systems Simulation (VSS), and overrides VSS's force-on-at-entry behaviour without modifying it.
- **Enhanced Vehicle System:** works alongside EVS, including its headlight flash. Nothing extra to install.

## Requirements

- [redscript](https://www.nexusmods.com/cyberpunk2077/mods/1511)
- [RED4ext](https://www.nexusmods.com/cyberpunk2077/mods/2380)
- [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780)

Optional:
- [Mod Settings](https://www.nexusmods.com/cyberpunk2077/mods/4885) - adds the in-game options page. Without it the defaults apply.

## Installation

Copy the `r6` folder into your Cyberpunk 2077 install folder, so the scripts end up at:

```
Cyberpunk 2077\r6\scripts\AutoHeadlights\AutoHeadlights.reds
Cyberpunk 2077\r6\scripts\AutoHeadlights\AutoHeadlightsLocalization.reds
```

## Settings

In game: **Settings → Mods → Auto Headlights** (needs Mod Settings). Without Mod Settings the defaults in this table apply.

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
| Traffic | Control traffic headlights | Off |
| Traffic | Traffic tunnel range (m) | 100 |
| Debug | Debug logging | Off |
| Debug | Traffic: treat every road as a tunnel | Off |

Traffic uses the same hours, weather, tunnel and delay settings as your own vehicle. Parked vehicles are left alone. Switching the traffic option off puts the lights back the way they were.

The Debug settings are for testing: logging writes to the Cyber Engine Tweaks log, and "treat every road as a tunnel" makes nearby traffic act as if it were under cover, so tunnel switching can be checked anywhere.

## Translations

The mod's on-screen messages are registered with Codeware's localization system, so they can be translated without touching the main script. The English text and a how-to are in `AutoHeadlightsLocalization.reds`; to add a language, copy the English class, translate it and return it for that language. Translations are welcome. The Mod Settings page is English only.

## Notes

- With Enhanced Vehicle System installed, turn off EVS's headlights time sync so only one mod decides when the lights come on.
- Other headlight mods may conflict.

## Credits

- [Enhanced Vehicle System](https://www.nexusmods.com/cyberpunk2077/mods/11765) is by hgyi56. Auto Headlights does not include or change any of its files.

## License

Released under the [MIT License](LICENSE). You are free to use, modify and redistribute this code, including in your own mods, as long as the copyright notice is kept.
