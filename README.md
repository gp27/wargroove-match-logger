# Wargroove Match Logger 1.0

A mod for Wargroove.
It saves matches as files locally or online. They can later be opened with the [Wargroove Match Viewer](https://wgroove.tk) to be replayed, analyzed etc.

## Installation
Downloaded the lateset release [here](https://github.com/gp27/wargroove-match-logger/releases)
Unzip it and place it in:

`C:\Users\[your-user]\%appdata%\Roaming\Chucklefish\Wargroove\mods`


## Settings

You can configure a few options by creating a file named `wgml-settings.txt` in the Wargroove install directory

`C:\Program Files (x86)\Steam\steamapps\common\Wargroove`
### wgml-settings.txt
```
save_online = false
open_browser = true
```

- **save_online**: if set to true, all your matches will be saved online
- **open_browser**: if set to true a browser tab will be automatically opened when you start / resume a match (only if the match is saved online)

## Requirements
- cURL - It should be preinstalled on Windows 10 (build >= 17063). Alternatively you can download it ([cURL](https://curl.se/windows/)) and place it in `C:\Windows\System32\`

## Related
## [Wargroove Match Viewer](https://wgroove.tk)
### [Wargroove Match Viewer (Github)](https://github.com/gp27/wargroove-match-viewer)