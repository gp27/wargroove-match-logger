# Wargroove Match Logger 1.0

A mod for Wargroove.
It saves matches as files locally or online. They can later be opened with the [Wargroove Match Viewer](https://wgroove.tk) to be replayed, analyzed etc.

## Installation
Downloaded the lateset release [here](https://github.com/gp27/wargroove-match-logger/releases)
Unzip it and place it in:

`C:\Users\[your-user]\%appdata%\Roaming\Chucklefish\Wargroove\mods`

## How does it work?
When you enable the mod and start a match, a file `.json` with a unique name will be created in the `matches` folder, under the Wargroove install directory:

`C:\Program Files (x86)\Steam\steamapps\common\Wargroove\matches\`

The file is updated every time a a player makes a move.

You can drag and drop the file on https://wgroove.tk to view the match.

If you enabled the `save_online` option a command line window will open when you start the match. You can minimize this window, but if you close it the online match will stop being updated (the local copy will still be saved correctly).

If a match is saved online you can just refresh the browser tab in the match viewer to see the latest moves. You can also share the link with anyone and it will work for them as well.

## Settings

You can configure a few options by creating a file named `wgml-settings.txt` in the Wargroove install directory

`C:\Program Files (x86)\Steam\steamapps\common\Wargroove`
### wgml-settings.txt
```
save_online = false
open_browser = true
```

- **save_online**: if set to true, all your matches will be saved online
- **open_browser**: if set to true a browser tab will be automatically opened when you start / resume a match (only if the match is saved online). I suggest to leave this option enabled for now. In the future it will be possibile to open the browser with an action from the HQ. 

## Requirements
- cURL - It should be preinstalled on Windows 10 (build >= 17063). Alternatively you can download it ([cURL](https://curl.se/windows/)) and place it in `C:\Windows\System32\`

## Related
### [Wargroove Match Viewer](https://wgroove.tk)
#### [Wargroove Match Viewer (Github)](https://github.com/gp27/wargroove-match-viewer)