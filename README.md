# ld46
Ludum Dare 46 Entry

# Installing

Make sure you clone the project to (on Mac) `~/Documents/The Electric Toy Co/freshly/games/ld46/`.

# Resource Rules

## Sprites

- All live in `sprites.png`
- Has to be in PNG format (includes transparency)
- sprites.png each dimension must be a power of 2 (...256, 512, 1024, 2048)
- Image can be no larger than 2048 on each side
- Consists of "cells" that are square and a power of 2 (...8, 16, 32, 64...)
- Sprites can span cells, but are drawn as a rectangle of cells

## Audio

- Lives in the `audio/` folder.
- .mp3 or .wav files.

## Map

- Use the "Tiled" editor to create
- Output is a .tmx file
- Use `sprites.png` as the base spritesheet
- .tsx file is ignored.

# Tools

BFXR: https://www.bfxr.net/
The "Tiled" Map Editor: https://www.mapeditor.org/

# TODO

1. BUG Fix audio crackling
1. Emscripten version
1. Windows version
1. Linux version

1. Title screen/logo (w/ credits)
1. Suppress monsters in starting area
1. SFX: Footsteps
1. Spawn balance - difficulty
1. BUG: Availability, inventory > 9                   ?

1. GOAL AMOUNT = $100                                                       X
1. Water color                                                              X
1. Market explanation                                                       X
1. Pickup sound                                                             X
1. Crystal from shop only                                                   X
1. Ending stops                                                             X
1. Draw inventory in some form                                              X
1. Market availability gains                                                X
1. Bug: can't buy                                                           X
1. Final map and town placement.                                            X
1. Text talk sfx                                                            X
1. Other music for family talking                                           X
1. SFX: Break barrier                                                       X
1. Player health, death, restart                                            X
    - Health heart                                                          X
    - Death animation                                                       X
    - Death mode                                                            X
    - Restart page                                                          X
1. Trees, obstacles                                                         X
1. Enemy run animation slows when they slow; speed dependent on speed       X
1. Creatures should puff out of existence                                   X
1. More interesting mob behavior/AI (mob health?)                           X
1. Markets and inventory                                                    X
1. Towns                                                                    X
1. Story intro, ending                                                      X
    - Blockage                                                              X
    - Sword gain                                                            X
    - Children                                                              X
    - Ending                                                                X
    - Ending proper (fade out etc.)                                         X
1. Screen effects (chromatic...)                                            X
1. Commodities                                                              X
    - Improved drop proportions                                             X
    - Hidden/dug items                                                      X
1. Sound effects
    - Coin
    - Pickup commodity
    - Pickup health (eating)
    - Ouch
    - Swipe sword
    - Hit monster
    - Monster die
    - Monster notice you
    - You die
    - Game start
    - Finish market transaction
    - Text type blips
    - Jelly squish
1. Music
1. Story husband character, conversation                                   X
1. Story children character, conversation                                  X

# Notes

stick - 25%
flowers and bug = 50%
herbs = 75%