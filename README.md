# Raid-Consumes (Vanilla 1.12.1)

**Raid-Consumes** is a comprehensive World of Warcraft (1.12.1) addon that provides an intelligent consumable management system with a visual GUI interface. It tracks buffs, manages cooldowns, and helps you efficiently use consumables during raids and dungeons.

**Latest Update:** Major overhaul with separate windows functionality, extended consumable support (25+ items), enhanced visual indicators, and comprehensive on-use item management including protection potions and instant-effect consumables.

## If you would like other consumables to be added, please let me know by opening an issue and giving me a list. Preferably provide the ItemID and BuffID, which both can be found on the database (https://database.turtle-wow.org/).
1. https://database.turtle-wow.org/?item=12451 <--- 12451 is the ItemID
2. Click on the buff that is listed on the item, which takes you to the buff it gives you. https://database.turtle-wow.org/?spell=16323 <--- 16323 is the buffID

---

## Features

### Smart Consumable Management
- **Automatic buff checking** - Only uses consumables when needed
- **Threshold-based reapplication** - Set custom timing for buff renewal
- **Inventory tracking** - Shows item counts with color-coded warnings
- **Individual & shared cooldowns** - Proper cooldown management for all consumable types
- **Support for 25+ consumables** per window

### GUI
- **Visual button interface** - Click consumables directly from the GUI
- **Real-time status indicators** - Green (active), Red (cooldown), Yellow (pending)
- **Item count display** - See how many of each consumable you have
- **Flexible layouts** - Horizontal or vertical button arrangements
- **Draggable windows** - Position frames anywhere on screen

### Dual Window Modes
- **Single Window Mode** - All consumables in one frame (classic mode)
- **Separate Windows Mode** - Split on-use and regular consumables into dedicated windows
- **Smart filtering** - Show only on-use consumables when needed

### On-Use Item Support
- **Protection potions** - All elemental and magic resistance potions
- **Combat consumables** - Rage potions, quick-use buffs
- **Special items** - Nordanaar Herbal Tea, Free Action Potions
- **Instant effects** - Items without buffs (like healing consumables)

### Persistent Settings
- **Session memory** - All settings saved between game sessions
- **Position memory** - Window positions preserved
- **Selection memory** - Chosen consumables remembered

---

## Installation

1. Download the addon's folder (named `RaidingConsumes`).
2. Place it inside your WoW Classic 1.12.1 `Interface\AddOns\` directory.
3. Make sure the folder structure is correct:
  `.../Interface/AddOns/RaidingConsumes/RaidingConsumes.lua`
  `.../Interface/AddOns/RaidingConsumes/RaidingConsumes.toc`
  (And any other files the addon might include.)
4. Launch (or re-launch) WoW 1.12.1, and enable "Load Out of Date AddOns" if necessary.

Alternatively, use GitHub Addon Manager to automatically install.

---

## Quick Start

1. **Choose your consumables** by typing `/rc <consumable names>`.
2. **View GUI** by typing `/rc` (toggles visibility).
3. **Apply all consumables** anytime with `/usecons`.
4. **Click individual items** directly from the GUI buttons.
5. If you want to adjust **how soon** before a buff ends that you reapply it, use `/rc threshold <seconds>`.

---

## Commands

### Basic Commands

#### `/rc [consumable names separated by commas]`
- **Description**: Add new consumables to your selection.
- **Example**:
 - `/rc Juju Power, Elixir of the Mongoose`
   - Adds *Juju Power* and *Elixir of the Mongoose* to your saved list.
 - You can run this multiple times to add more. It will **not** overwrite older entries.

#### `/rc`
- **Description**: Toggle GUI visibility.
- **Behavior**: Shows or hides the consumable interface.

#### `/rc list`
- **Description**: Shows a list of all currently selected consumables and current settings.

#### `/usecons`
- **Description**: Attempts to apply all consumables you've selected (if you have them in your bags and do not have the buff or the buff is below the threshold).
- **Behavior**:
 - Will check each buff, see if it's missing or nearing expiry, and use the corresponding item if you have it.
 - If you *don't* have the item, you'll get a "You need to restock" message—but only once every 10 seconds to prevent spam.

### Configuration Commands

#### `/rc threshold <seconds>`
- **Description**: Sets the time threshold (in seconds) to reapply a buff.
- **Example**:
 - `/rc threshold 120`
   - Means if the buff has 120 seconds (2 minutes) or less remaining, the addon will try to consume that item again.

#### `/rc vertical`
- **Description**: Switch GUI to vertical button layout (top to bottom).

#### `/rc horizontal`
- **Description**: Switch GUI to horizontal button layout (left to right).

### Window Mode Commands

#### `/rc onuseonly`
- **Description**: Toggle showing only On-Use consumables in single window mode.
- **Behavior**: Filters the main window to show only items that require activation (protection potions, rage potions, etc.).
- **Note**: Automatically disables separate windows mode if active.

#### `/rc separateconsumes`
- **Description**: Toggle separate windows mode for on-use and regular consumables.
- **Behavior**: Creates two separate windows - one for on-use items, one for regular consumables.
- **Note**: Automatically disables onuseonly filter if active.

### Management Commands

#### `/rc remove <consumable>`
- **Description**: Selectively removes consumables from your rotation.
- **Example**:
 - `/rc remove Elixir of the Mongoose`
   - Will remove only Elixir of the Mongoose from your `/usecons` consumable list. Use `/rc list` to verify.

#### `/rc reset`
- **Description**: Resets and clears **all** currently selected consumables from your table.

#### `/rc help`
- **Description**: Shows all available commands in-game.

---

## Visual Indicators

### Button States
- **Green Overlay**: Buff is active, shows remaining time
- **Red Overlay**: Item on cooldown, shows cooldown timer
- **Yellow Overlay**: Item use pending confirmation (shows "WAIT")
- **Dimmed**: No buff active (regular consumables only)
- **Full Brightness**: Ready to use

### Item Count Colors
- **White**: 4+ items available
- **Orange**: 1-3 items (low stock warning)
- **Red**: 0 items (out of stock)

---

## Usage Modes

### Single Window Mode (Default)
- All consumables displayed in one frame
- Optional filtering with `/rc onuseonly`
- Classic experience with enhanced features

### Separate Windows Mode
- **On-Use Window**: Protection potions, rage potions, instant effects
- **Regular Window**: Elixirs, flasks, food buffs
- Independent positioning and management
- Activated with `/rc separateconsumes`

---

## Advanced Features

### Cooldown Management
- **Shared Cooldowns**: 2-minute cooldown for most on-use items
- **Individual Cooldowns**: Special tracking for Juju items (1 min) and Nordanaar Tea (2 min)
- **Pending System**: Tracks item usage until buff confirmation or timeout

### Smart Buff Detection
- **Threshold System**: Customizable time remaining before reapplication
- **Buff Conflict Resolution**: Prevents using items when buffs are already active
- **Eating/Drinking Detection**: Blocks consumable use during food/drink consumption

### GUI Customization
- **Layout Options**: Horizontal or vertical button arrangements
- **Window Positioning**: Draggable frames with position memory
- **Dynamic Sizing**: Frames automatically resize based on content
- **Button Limit**: Supports up to 25 consumables per window

---

## Troubleshooting

### Common Issues
- **Addon not loading**: Enable "Load Out of Date AddOns" in Interface options
- **GUI not showing**: Type `/rc` to toggle visibility
- **Consumables not working**: Verify items are in your bags with `/rc list`
- **Cooldowns not working**: Some items share cooldowns - this is normal behavior
- **Separate windows not showing**: Use `/rc separateconsumes` to toggle the mode

### Getting Help
- Use `/rc help` for command reference
- Check `/rc list` to verify your current settings
- Report issues on GitHub with specific item names and behavior

---

## Contributing

### Adding New Consumables
To request new consumables, please open an issue with:
1. **Item Name**: Full in-game name
2. **Item ID**: Found at `https://database.turtle-wow.org/?item=XXXXX`
3. **Buff ID**: Found by clicking the buff link on the item page
4. **Type**: Regular consumable or On-Use item

### Example Request Format
Item: Greater Arcane Elixir
Item ID: 13454
Buff ID: 17539
Type: Regular consumable (not on-use)

## Complete List of Supported Consumables

### Melee/Ranged Power/Crit Consumables
- **Juju Power** - Attack Power buff (30 minutes)
- **Elixir of Giants** - Strength buff (1 hour)
- **Winterfall Firewater** - Attack Power buff (20 minutes)
- **Juju Might** - Strength buff (10 minutes)
- **Elixir of Demonslaying** - Damage vs Demons (5 minutes)
- **Elixir of the Mongoose** - Agility & Critical Strike (1 hour)
- **Elixir of Greater Agility** - Agility buff (1 hour)
- **R.O.I.D.S** - Strength buff (1 hour)
- **Ground Scorpok Assay** - Agility buff (1 hour)
- **Bogling Root** - Stamina buff (10 minutes)
- **Danonzo's Tel'Abim Surprise** - Stamina & Spirit (15 minutes)
- **Sweet Mountain Berry** - Agility buff (10 minutes)
- **Grilled Squid** - Agility buff (10 minutes)
- **Danonzo's Tel'Abim Medley** - Strength & Stamina (15 minutes)
- **Smoked Desert Dumplings** - Strength buff (15 minutes)
- **Power Mushroom** - Strength buff (15 minutes)
- **Spicy Beef Burrito** - Strength buff (15 minutes)
- **Dragonbreath Chili** - Fire damage proc (10 minutes)

### Tank/Defensive/Stamina Consumables
- **Elixir of Superior Defense** - Armor buff (1 hour)
- **Elixir of Fortitude** - Health buff (1 hour)
- **Spirit of Zanza** - Stamina & Spirit (2 hours)
- **Flask of the Titans** - Health buff (2 hours)
- **Gift of Arthas** - Strength & Stamina (30 minutes)
- **Medivh's Merlot Blue** - Intellect & Stamina (15 minutes)
- **Medivh's Merlot** - Spirit & Stamina (15 minutes)
- **Scroll of Protection IV** - Armor buff (30 minutes)
- **Rumsey Rum Black Label** - Stamina buff (15 minutes)
- **Hardened Mushroom** - Stamina buff (15 minutes)
- **Dirge's Kickin' Chimaerok Chops** - Stamina buff (15 minutes)
- **Le Fishe Au Chocolat** - Stamina & Spirit (15 minutes)

### Mana User Consumables
- **Dreamshard Elixir** - Mana regeneration (1 hour)
- **Greater Arcane Elixir** - Spell damage (1 hour)
- **Dreamtonic** - Mana regeneration (20 minutes)
- **Flask of Supreme Power** - Spell damage (2 hours)
- **Mageblood Potion** - Mana regeneration (1 hour)
- **Cerebral Cortex Compound** - Intellect buff (1 hour)
- **Elixir of Shadow Power** - Shadow spell damage (30 minutes)
- **Juicy Striped Melon** - Intellect buff (15 minutes)
- **Flask of Distilled Wisdom** - Intellect buff (2 hours)
- **Danonzo's Tel'Abim Delight** - Intellect & Spirit (15 minutes)
- **Juju Guile** - Intellect buff (30 minutes)
- **Nightfin Soup** - Mana regeneration (10 minutes)

### On-Use Protection Potions
- **Greater Arcane Protection Potion** - Arcane resistance (1 hour)
- **Greater Frost Protection Potion** - Frost resistance (1 hour)
- **Frost Protection Potion** - Frost resistance (1 hour)
- **Greater Fire Protection Potion** - Fire resistance (1 hour)
- **Fire Protection Potion** - Fire resistance (1 hour)
- **Greater Holy Protection Potion** - Holy resistance (1 hour)
- **Holy Protection Potion** - Holy resistance (1 hour)
- **Greater Nature Protection Potion** - Nature resistance (1 hour)
- **Nature Protection Potion** - Nature resistance (1 hour)
- **Greater Shadow Protection Potion** - Shadow resistance (1 hour)
- **Shadow Protection Potion** - Shadow resistance (1 hour)
- **Magic Resistance Potion** - All magic resistance (3 minutes)
- **Greater Stoneshield Potion** - Armor buff (2 minutes)
- **Lesser Stoneshield Potion** - Armor buff (90 seconds)

### On-Use Combat Items
- **Juju Flurry** - Attack speed increase (20 seconds)
- **Mighty Rage Potion** - Rage generation (20 seconds)
- **Great Rage Potion** - Rage generation (20 seconds)
- **Potion of Quickness** - Haste increase (30 seconds)
- **Free Action Potion** - Immunity to movement impairing effects (30 seconds)
- **Restorative Potion** - Remove poison, disease, curse, magic (30 seconds)
- **Limited Invulnerability Potion** - Physical immunity (6 seconds)

### Special Juju Items (Individual Cooldowns)
- **Juju Escape** - Dodge increase (10 seconds)
- **Juju Ember** - Fire resistance (20 seconds)
- **Juju Chill** - Frost resistance (20 seconds)

### Uncategorized/Special Items
- **Swiftness of Zanza** - Movement speed (2 hours)
- **Elixir of Poison Resistance** - Poison resistance (instant)
- **Nordanaar Herbal Tea** - Instant healing effect (On-Use, instant)
- **Restorative Potion** - Removes 1 magic, curse, poison, or disease effect on you every 5 seconds for 30 seconds
- **Limited Invulnerability Potion** - Imbiber is immune to physical attacks for the next 6 seconds.
- **Dragonbreath Chili** - Mainly for degenerate paladins, figure it out.  
