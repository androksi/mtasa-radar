# MTA:SA Radar
#### This is a simple radar for your server. It has a menu which allows players to toggle player icons, blip icons and optimised mode.

### Normal
![Screenshot_1-removebg-preview](https://user-images.githubusercontent.com/73851736/122226964-d76e3780-ce8c-11eb-98a9-59c9d26b179f.png)
### Menu (ALT + Left Click on the radar)
![Screenshot_2-removebg-preview](https://user-images.githubusercontent.com/73851736/122227002-dfc67280-ce8c-11eb-8a5a-a549b27b2765.png)

## Features
##### ALT + Left Click on the radar - Toggle menu.
##### Right Click on the radar - Reset its position.
##### Drag - You can drag the radar.

## Menu Options
##### Show Blips - Toggle blips on the radar. (High CPU usage when enabled)
##### Show Players - Toggle player icons on the radar. (Also high CPU usage if enabled)
##### Optimised Mode - This option simply makes the render to use less CPU, by updating the RT (Render Target) every 1 sec, instead of every frame.

## Exported Functions (client-side only)
### toggleRadar
```lua
void toggleRadar ( bool bool )
```
