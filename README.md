# Undead's Medical

Welcome to Undead's Medical, a mod for Barotrauma that enhances the medical mechanics by introducing new items and afflictions to the game.

## Features

  - **Revived Affliction**: You have been brought back from death's door.
  - **Nanobots Affliction**: Nanobots are reviving you.
  - **Revive Serum**: A powerful mix to prevent eternal rest. Effective only on the dead.
  - **Nanobots**: A syringe full of tiny medical robots. They can heal everyone including previously revived people.
  - **Empty Syringe**: A empty syringe used for crafting.
  - **Refined Calyx Extract**: A more potent calyx extract.
  - **Symbiosis Syringe**: A syringe containing a refined symbiote, granting strength and awareness while binding host and parasite as one.
  - **Xenocrystal**: An alien crystal formed from various metals.

## Crafting

### Revive Serum
- **Ingredients**:
  - 2x Antibiotic Glue
  - 2x Haloperidol
  - 8x Calyx Extract
  - 16x Calcium
  - 3x Endocrine Booster
- **Requirements**: 80 Medical skill
- **Crafting Time**: 50 seconds

### Nanobots
- **Ingredients**:
  - 2x Xenocrystal
  - 2x Alien Circuitry
  - 8x Alien Blood
  - 1x Revive Syringe
- **Requirements**: 80 Medical skill, 40 Mechanical skill
- **Crafting Time**: 120 seconds

### Xenocrystal
- **Ingredients**:
  - 1x Dementonite
  - 8x Fulgurium
  - 4x Incendium
  - 2x Oxygenite Shard
  - 4x Physicorium
- **Requirements**: 80 Mechanical skill
- **Crafting Time**: 90 seconds

### Empty Syringe
- **Ingredients**:
  - 2x Silicon
- **Requirements**: 35 Medical skill
- **Crafting Time**: 15 seconds

### Refined Calyx Syringe
- **Ingredients**:
  - 4x Husk Eggs
  - 1x Xenocrystal
  - 2x Calyxanide
  - 1x Steroids
  - 1x Empty Syringe
- **Requirements**: 50 Medical skill
- **Crafting Time**: 30 seconds

### Symbiosis Syringe
- **Requirements**: TBD Medical skill
- **Crafting**: Must hit a character that already has symbiosis with a Refined Calyx Syringe.
- **Warning**: If the player does not have symbiosis, they will receive a large dose of husk infection.

## Configuration Options
- **Vanilla Damage Patch** (`RS_VanillaDMG`): Enables standard afflictions without requiring Neurotrauma. If enabled with Neurotrauma, vanilla afflictions will be disabled. Default: `true`
- **Neurotrauma Patch** (`NTRS`): Enables standard afflictions and afflictions from Neurotrauma. Includes vanilla afflictions unless Vanilla Damage Patch is enabled. Default: `false`
- **Cybernetics Enhanced Patch** (`NTCRS`): Allows the saving of Cyberlimbs and Cyberorgans. Default: `false`
- **Neurotrauma Eyes Patch** (`NTERS`): Allows the saving of Positive Neurotrauma Eye afflictions (e.g., Implanted Eyes). Default: `false`
- **Neurotrauma Removed Limb Patch** (`NTLRS`): Allows the saving of removed limbs. If Neurotrauma Eyes Patch is enabled, Neurotrauma Eye negative afflictions will be saved. Default: `false`
- **Instant Revive Patch** (`FD`): Removes injuries upon revival when using the Revive Serum. Do not use alongside Neurotrauma Patch or Vanilla Damage. Default: `false`
- **Revive Affliction** (`RS_Affliction`): Applies a custom affliction that makes the Revive Serum only work on characters without the affliction, restricting revival for affected individuals. Does not affect Nanobots. Default: `true`
- **No Revive** (`NOREV`): Prevents revival in cases of severe injuries such as extreme blood loss, gunshot wounds above a fatal threshold, pressure injuries, or missing vital limbs (e.g., head). Default: `true`

You can configure in game.

To install the mod, visit the [Steam Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3275278739) and subscribe to the mod.

## Contributors
- **Heelge**: Russian translation and config assistance.
- **Dr_Bruhman**: Original concept for Revive Serum.
- **Captain_Fight**: Expanded on their concept of Transferable Symbiosis.

## License
MIT License

Copyright (c) 2024 Undead's Medical Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
