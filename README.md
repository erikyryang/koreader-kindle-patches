# koreader-kindle-patches

User patches for [KOReader](https://github.com/koreader/koreader) on jailbroken Kindles.

A *user patch* is a Lua file that KOReader loads from `koreader/patches/` at startup. It changes KOReader's behavior without touching the original files, so it keeps working after KOReader updates.

## Patches

### `2-kindle-pause-native-statusbar.lua`

**Problem:** on Kindle firmware 5.16 and newer, the native status bar (`/app/bin/JunoStatusBarDriver`) keeps drawing its clock on top of KOReader every minute. You see something like "12:29 PM" overlaid in the top-left corner, sometimes with the previous minute ghosting underneath. KOReader's startup script pauses the old window manager (`awesome`), but it doesn't know about this newer status bar.

**Fix:** the patch sends `SIGSTOP` to `JunoStatusBarDriver` when KOReader starts and `SIGCONT` when you exit through KOReader's menu, so the native Kindle UI goes back to normal.

- It only acts on Kindle devices. On other devices it does nothing.
- If KOReader crashes or is force-killed, the native status bar may stay paused until the next time KOReader starts or the Kindle reboots.

### `2-reader-center-double-tap-goto.lua`

**What it does:** in the reader, a **double tap in the center of the screen** opens the **"Go to page"** dialog. This is the same "Go to" action that KOReader's menu and gestures already use.

- The center zone is the middle half of the screen, from 25% to 75% horizontally and vertically.
- It takes priority over the double tap zones of the gestures plugin (the sides and corners).
- **Double tap detection must be enabled.** In KOReader, turn on double tap under *Settings → Taps and gestures*, or set `disable_double_tap = false` in `settings.reader.lua`. With it on, every single tap waits for the double tap interval (about 0.3 s) before turning the page. You can adjust the interval under *Taps and gestures → Gesture intervals*.

## Installation

1. Copy the `.lua` files from `patches/` to `koreader/patches/` on the Kindle (on the device: `/mnt/us/koreader/patches/`). Create the folder if it doesn't exist.
2. Restart KOReader.
3. To confirm, look for `Applying patch:` in `koreader/crash.log`.

Over KOReader's SSH server (port 2222):

```sh
scp -P 2222 patches/*.lua root@<kindle-ip>:/mnt/us/koreader/patches/
```

The files must use **LF** line endings. This repository's `.gitattributes` enforces that.

## Removal

Delete the file from `koreader/patches/` and restart KOReader. To turn off **all** patches at once without deleting anything, use the option to disable user patches in KOReader's menu.

## Tested on

| Item | Version |
|---|---|
| Device | Kindle Basic 5 (Rossini, MT8110 Bellatrix) |
| Firmware | 5.19.5 |
| KOReader | v2026.07.2 (kindlehf, installed via KPM) |
| Jailbreak | KindleModding hotfix v2.5.0 |

## License

[MIT](LICENSE). KOReader itself is licensed under the AGPL-3.0; these patches only use its public APIs at runtime.
