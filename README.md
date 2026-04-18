# Characters
A Luanti Player API designed with compatability in mind. Player Models and physical entities (Characters) are customizeable and can be compatible with any game with the addition of a compat mod.

## Compat Modules

Compat mods allow you to tell the Character API what model to use and perform your own animation code with Character API callbacks while the Character API will handle all the internal things such as synchronization and Engine interaction.

### Default Compat

If a game doesn't have a compat module, you can use the default compat module. The default compat is a solid foundation and you shouldn't need to make a compat mod in most cases. Some games however add mechanics that should be animated/handled by a seperate compat.

### Why use a Compat?

Compats allow you to setup your animations and model per-game, letting different games handle players differently while everthing is still compatible with other Characters API compatible features.

Games such as Mintest Game, which have the Player API mod shouldn't need anything more than the default compat, unless there are custom animations and such. The default compat has been designed to provide compatibility with mods such as Player API. Which allows you to drop in Characters API without reworking the source game.

Some games however, are more creative with their player mechanics, such as Voxelibre (and other MCL derivatives). For these games, compat mods can be made by anyone and dropped into the instance. For games such as 1042, that use Characters API builtin it is even easier, the game bundles a compat mod that handles all the custom animations and interactions needed, while still allowing Addons and compatible features.

## Features

Beyond Compat modules handling animations and other game specific player interactions, Character API comes with several Compatible Features. As well as the ability to install Addons.

### Builtin Compatible Features

Packed with the modpack, you'll find these features:

---

Mod Compats: **(WIP)**
* SkinsDB Compat
* 3D Armor Compat

---

Character Features: **(WIP)**
* Emote Interaction (has to be configured in the game compat)
* Attachments
  * Capes
  * Cosmetics
* Multi-Layered Skins
* Sequenced Animations

---

Default Compat:
* Head Animation (look pitch)
* Variable speed animations (such as walking)

## Contribution

**We're looking for experienced developers who would like to maintain this project and keep it compatible!**

This project probably isn't going to disappear without you, but it doesn't hurt to help.

### How can I help?

Contact me on the Luanti discord, or just start making pull requests and posting issues.

_The more the merrier..._