# Raid-Consumes (Vanilla 1.12.1)

**Raid-Consumes** is a lightweight World of Warcraft (1.12.1) addon that lets you specify consumables to automatically apply with a single button. It checks if you have the buff already and if you have the consumable in your bags, then uses it. If you don't have it, you'll get a one-time restock warning.

## If you would like other consumables to be added, please let me know by opening an issue and giving me a list. Preferably provide the ItemID and BuffID, which both can be found on the database (https://database.turtle-wow.org/). 
1. https://database.turtle-wow.org/?item=12451 <--- 12451 is the ItemID
2. Click on the buff that is listed on the item, which takes you to the buff it gives you. https://database.turtle-wow.org/?spell=16323 <--- 16323 is the buffID

---

## Features

- **Selectable consumables** via a simple in-game command (`/rc`).
- **Automatic checks** for existing buffs and threshold times remaining.
- **Smart usage**: Only uses consumables if you need them.
- **Cooldown** on restock messages to avoid spam.
- **Saves your choices** across sessions.

---

## Installation

1. Download the addon's folder (named, for example, `RaidingConsumes`).
2. Place it inside your WoW Classic 1.12.1 `Interface\AddOns\` directory.
3. Make sure the folder structure is correct:  
   `.../Interface/AddOns/RaidingConsumes/RaidingConsumes.lua`  
   `.../Interface/AddOns/RaidingConsumes/RaidingConsumes.toc`  
   (And any other files the addon might include.)
4. Launch (or re-launch) WoW 1.12.1, and enable “Load Out of Date AddOns” if necessary.

Alternatively, use Githubaddonmanager to automatically install.

---

## Usage

1. **Choose your consumables** by typing `/rc <consumable names>`. 
2. Use `/rc list` to see all the consumables you’ve added so far.
3. **Apply** them anytime with `/usecons`.
4. If you ever need to **reset** your choices, do `/rc reset`.
5. If you want to adjust **how soon** before a buff ends that you reapply it, use `/rc threshold <seconds>`.

---

## Commands

### `/rc [consumable names separated by commas]`
- **Description**: Add new consumables to your selection.  
- **Example**:  
  - `\rc Juju Power, Elixir of the Mongoose`  
    - Adds *Juju Power* and *Elixir of the Mongoose* to your saved list.  
  - You can run this multiple times to add more. It will **not** overwrite older entries if you’ve set it up to accumulate.

### `/rc list`
- **Description**: Shows a list of all currently selected consumables in your saved table.

### `/rc threshold <seconds>`
- **Description**: Sets the time threshold (in seconds) to reapply a buff.  
- **Example**:  
  - `\rc threshold 120`  
    - Means if the buff has 120 seconds (2 minutes) or less remaining, the addon will try to consume that item again.

### `/rc reset`
- **Description**: Resets and clears **all** currently selected consumables from your table.

### `/usecons`
- **Description**: Attempts to apply all consumables you’ve selected (if you have them in your bags and do not have the buff or the buff is below the threshold).  
- **Behavior**:  
  - Will check each buff, see if it’s missing or nearing expiry, and use the corresponding item if you have it.  
  - If you *don’t* have the item, you’ll get a “You need to restock” message—but only once every 10 seconds to prevent spam.
