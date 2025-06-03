# Raid-Consumes (Vanilla 1.12.1)

Raid-Consumes is a comprehensive World of Warcraft (1.12.1) addon that provides an intelligent consumable management system with a visual GUI interface. It tracks buffs, manages cooldowns, and helps you efficiently use consumables during raids and dungeons.

✨ Features
Automatic buff checking - Only uses consumables when needed
Threshold-based reapplication - Set custom timing for buff renewal
Inventory tracking - Shows item counts with color-coded warnings
Individual & shared cooldowns - Proper cooldown management for all consumable types

🖥️ GUI 

Visual button interface - Click consumables directly from the GUI
Real-time status indicators - Green (active), Red (cooldown), Yellow (pending)
Item count display - See how many of each consumable you have
Flexible layouts - Horizontal or vertical button arrangements
Draggable windows - Position frames anywhere on screen

🪟 Dual Window Modes

Single Window Mode - All consumables in one frame (classic mode)
Separate Windows Mode - Split on-use and regular consumables into dedicated windows
Smart filtering - Show only on-use consumables when needed

⚡ On-Use Item Support

Protection potions - All elemental and magic resistance potions
Combat consumables - Rage potions, quick-use buffs
Special items - Nordanaar Herbal Tea, Free Action Potions
Instant effects - Items without buffs (like healing consumables)


📦 Installation
Method 1: Manual Installation

Download the addon folder (RaidingConsumes)
Place it in your WoW Classic 1.12.1 Interface\AddOns\ directory
Ensure correct folder structure:
.../Interface/AddOns/RaidingConsumes/RaidingConsumes.lua
.../Interface/AddOns/RaidingConsumes/RaidingConsumes.toc

Launch WoW and enable "Load Out of Date AddOns" if necessary

Method 2: GitHub Addon Manager
Use GitHub Addon Manager for automatic installation and updates.

🚀 Quick Start

Select consumables: /rc Juju Power, Elixir of the Mongoose
View GUI: /rc (toggles visibility)
Use all consumables: /usecons
Help menu: /rc help
Click individual items directly from the GUI buttons


📋 Complete Command Reference
Basic Commands
CommandDescriptionExample/rcToggle GUI visibility/rc/rc [items]Add consumables to selection/rc Juju Power, Flask of Titans/rc listShow selected consumables and settings/rc list/useconsApply all selected consumables/usecons
Configuration Commands
CommandDescriptionExample/rc threshold [seconds]Set buff reapplication threshold/rc threshold 120/rc verticalSwitch to vertical button layout/rc vertical/rc horizontalSwitch to horizontal button layout/rc horizontal
Window Mode Commands
CommandDescriptionExample/rc onuseonlyShow only on-use consumables/rc onuseonly/rc separateconsumesToggle separate windows mode/rc separateconsumes
Management Commands
CommandDescriptionExample/rc remove [item]Remove specific consumable/rc remove Juju Power/rc resetClear all selected consumables/rc reset/rc helpShow all available commands/rc help

🎮 Usage Modes
Single Window Mode (Default)

All consumables displayed in one frame
Optional filtering with /rc onuseonly
Classic experience with enhanced features

Separate Windows Mode

On-Use Window: Protection potions, rage potions, instant effects
Regular Window: Elixirs, flasks, food buffs
Independent positioning and management
Activated with /rc separateconsumes


🎨 Visual Indicators
Button States

🟢 Green Overlay: Buff is active, shows remaining time
🔴 Red Overlay: Item on cooldown, shows cooldown timer
🟡 Yellow Overlay: Item use pending confirmation
⚪ Dimmed: No buff active (regular consumables only)
⚡ Full Brightness: Ready to use

Item Count Colors

⚪ White: 4+ items available
🟠 Orange: 1-3 items (low stock warning)
🔴 Red: 0 items (out of stock)


🧪 Supported Consumables
Combat Buffs

Melee/Ranged: Juju Power, Elixir of the Mongoose, Winterfall Firewater
Caster: Greater Arcane Elixir, Flask of Supreme Power, Cerebral Cortex Compound
Tank/Defense: Elixir of Superior Defense, Flask of the Titans, Gift of Arthas

Protection Potions (On-Use)

Elemental: Fire, Frost, Nature, Arcane Protection Potions
Magical: Shadow, Holy Protection Potions
Physical: Stoneshield Potions, Magic Resistance Potions

Special Items

Combat: Rage Potions, Free Action Potions, Limited Invulnerability
Utility: Nordanaar Herbal Tea, Restorative Potions

Food & Temporary Buffs

Stat Foods: Grilled Squid, Smoked Desert Dumplings, Power Mushrooms
Zanza Buffs: Spirit/Swiftness of Zanza
Special: Rumsey Rum, Dirge's Kickin' Chimaerok Chops

*** Please see code or try to add other consumables in-game to see if available. See below for making a request to add more consumables to the list


🔧 Advanced Features
Cooldown Management

Shared Cooldowns: 2-minute cooldown for most on-use items
Individual Cooldowns: Special tracking for Juju items (1 min) and Nordanaar Tea (2 min)
Pending System: Tracks item usage until buff confirmation

Smart Buff Detection

Threshold System: Customizable time remaining before reapplication
Buff Conflict Resolution: Prevents using items when buffs are already active
Eating/Drinking Detection: Blocks consumable use during food/drink consumption

GUI Customization

Layout Options: Horizontal or vertical button arrangements
Window Positioning: Draggable frames with position memory
Dynamic Sizing: Frames automatically resize based on content
Button Limit: Supports up to 25 consumables per window


❓ Troubleshooting
Common Issues

Addon not loading: Enable "Load Out of Date AddOns" in Interface options
GUI not showing: Type /rc to toggle visibility
Consumables not working: Verify items are in your bags with /rc list
Cooldowns not working: Some items share cooldowns - this is normal behavior

Getting Help

Use /rc help for command reference
Check /rc list to verify your current settings
Report issues on GitHub with specific item names and behavior


🔄 Recent Updates
Latest Version Features

✅ Extended support for 25+ consumables
✅ Separate windows for on-use vs regular consumables
✅ Enhanced visual indicators and timers
✅ Improved cooldown tracking system
✅ Better item count display with color coding
✅ Persistent window positioning


🤝 Contributing
Adding New Consumables
To request new consumables, please open an issue with:

Item Name: Full in-game name
Item ID: Found at https://database.turtle-wow.org/?item=XXXXX
Buff ID: Found by clicking the buff link on the item page

Example Request Format
Item: Greater Arcane Elixir
Item ID: 13454
Buff ID: 17539
Type: Regular consumable (not on-use)

📄 License
This addon is open source and available for community use and modification.
