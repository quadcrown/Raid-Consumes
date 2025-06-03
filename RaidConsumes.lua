-- Global variable for shared On Use cooldown
local lastOnUseTime = 0
local ON_USE_COOLDOWN = 120 -- 2 minutes in seconds

-- Individual cooldown tracking for special items
local individualCooldowns = {} -- itemID -> timestamp when used
local JUJU_COOLDOWN = 60 -- 1 minute for Juju items
local NORDANAAR_COOLDOWN = 120 -- 2 minutes for Nordanaar Herbal Tea

-- Table to track pending on-use items (itemID -> timestamp when used)
local pendingOnUseItems = {}
local PENDING_TIMEOUT = 5 -- 5 seconds to detect if buff appeared

-- Complete database of consumables: itemID -> {buffID, name, icon, duration, isOnUse}
local consumablesDB = {
    -- Melee/ranged power/crit consumables
    [12451] = {buffID = 16323, name = "Juju Power", icon = "Interface\\Icons\\INV_Misc_MonsterScales_11", duration = 1800},
    [9206]  = {buffID = 11405, name = "Elixir of Giants", icon = "Interface\\Icons\\INV_Potion_61", duration = 3600},
    [12820] = {buffID = 17038, name = "Winterfall Firewater", icon = "Interface\\Icons\\INV_Potion_92", duration = 1200},
    [12460] = {buffID = 16329, name = "Juju Might", icon = "Interface\\Icons\\INV_Misc_MonsterScales_07", duration = 600},
    [9224]  = {buffID = 11406, name = "Elixir of Demonslaying", icon = "Interface\\Icons\\INV_Potion_27", duration = 300},
    [13452] = {buffID = 17538, name = "Elixir of the Mongoose", icon = "Interface\\Icons\\INV_Potion_32", duration = 3600},
    [9187]  = {buffID = 11334, name = "Elixir of Greater Agility", icon = "Interface\\Icons\\INV_Potion_94", duration = 3600},
    [8410]  = {buffID = 10667, name = "R.O.I.D.S", icon = "Interface\\Icons\\INV_Stone_15", duration = 3600},
    [8412]  = {buffID = 10669, name = "Ground Scorpok Assay", icon = "Interface\\Icons\\INV_Misc_Dust_02", duration = 3600},
    [5206]  = {buffID = 5665, name = "Bogling Root", icon = "Interface\\Icons\\INV_Misc_Herb_07", duration = 600},
    [12450] = {buffID = 16322, name = "Juju Flurry", icon = "Interface\\Icons\\INV_Misc_MonsterScales_17", duration = 20, isOnUse = true},
    [60976] = {buffID = 57042, name = "Danonzo's Tel'Abim Surprise", icon = "Interface\\Icons\\INV_Misc_Food_09", duration = 900},
    [51711] = {buffID = 18192, name = "Sweet Mountain Berry", icon = "Interface\\Icons\\INV_Misc_Food_40", duration = 600},
    [13928] = {buffID = 18192, name = "Grilled Squid", icon = "Interface\\Icons\\INV_Misc_Food_13", duration = 600},
    [60978] = {buffID = 57046, name = "Danonzo's Tel'Abim Medley", icon = "Interface\\Icons\\INV_Misc_Food_73", duration = 900},
    [20452] = {buffID = 24799, name = "Smoked Desert Dumplings", icon = "Interface\\Icons\\INV_Misc_Food_64", duration = 900},
    [51720] = {buffID = 24799, name = "Power Mushroom", icon = "Interface\\Icons\\INV_Mushroom_14", duration = 900},
    [51267] = {buffID = 24799, name = "Spicy Beef Burrito", icon = "Interface\\Icons\\INV_Misc_Food_49", duration = 900},
    [13442] = {buffID = 17528, name = "Mighty Rage Potion", icon = "Interface\\Icons\\INV_Potion_125", duration = 20, isOnUse = true},
    [5633]  = {buffID = 6613, name = "Great Rage Potion", icon = "Interface\\Icons\\INV_Potion_21", duration = 20, isOnUse = true},
    -- Tank/Defensive/Stamina consumables
    [13445] = {buffID = 11348, name = "Elixir of Superior Defense", icon = "Interface\\Icons\\INV_Potion_66", duration = 3600},
    [3825]  = {buffID = 3593, name = "Elixir of Fortitude", icon = "Interface\\Icons\\INV_Potion_43", duration = 3600},
    [20079] = {buffID = 24382, name = "Spirit of Zanza", icon = "Interface\\Icons\\INV_Potion_30", duration = 7200},
    [13510] = {buffID = 17626, name = "Flask of the Titans", icon = "Interface\\Icons\\INV_Potion_62", duration = 7200},
    [9088]  = {buffID = 11371, name = "Gift of Arthas", icon = "Interface\\Icons\\INV_Potion_28", duration = 1800},
    [61175] = {buffID = 57107, name = "Medivh's Merlot Blue", icon = "Interface\\Icons\\INV_Potion_61", duration = 900},
    [61174] = {buffID = 57106, name = "Medivh's Merlot", icon = "Interface\\Icons\\INV_Misc_Ribbon_01", duration = 900},
    [10305] = {buffID = 12175, name = "Scroll of Protection IV", icon = "Interface\\Icons\\INV_Scroll_07", duration = 1800},
    [21151] = {buffID = 25804, name = "Rumsey Rum Black Label", icon = "Interface\\Icons\\INV_Drink_04", duration = 900},
    [12459] = {buffID = 16321, name = "Juju Escape", icon = "Interface\\Icons\\INV_Misc_MonsterScales_17", duration = 10},
    [12455] = {buffID = 16326, name = "Juju Ember", icon = "Interface\\Icons\\INV_Misc_MonsterScales_15", duration = 20},
    [12457] = {buffID = 16325, name = "Juju Chill", icon = "Interface\\Icons\\INV_Misc_MonsterScales_09", duration = 20},
    [51717] = {buffID = 25661, name = "Hardened Mushroom", icon = "Interface\\Icons\\INV_Mushroom_15", duration = 900},
    [21023] = {buffID = 25661, name = "Dirge's Kickin' Chimaerok Chops", icon = "Interface\\Icons\\INV_Misc_Food_65", duration = 900},
    [84040] = {buffID = 45623, name = "Le Fishe Au Chocolat", icon = "Interface\\Icons\\INV_Misc_MonsterScales_11", duration = 900},
    -- Mana user consumables
    [61224] = {buffID = 45427, name = "Dreamshard Elixir", icon = "Interface\\Icons\\INV_Potion_12", duration = 3600},
    [13454] = {buffID = 17539, name = "Greater Arcane Elixir", icon = "Interface\\Icons\\INV_Potion_25", duration = 3600},
    [61423] = {buffID = 45489, name = "Dreamtonic", icon = "Interface\\Icons\\INV_Potion_10", duration = 1200},
    [13512] = {buffID = 17628, name = "Flask of Supreme Power", icon = "Interface\\Icons\\INV_Potion_41", duration = 7200},
    [20007] = {buffID = 24363, name = "Mageblood Potion", icon = "Interface\\Icons\\INV_Potion_45", duration = 3600},
    [8423]  = {buffID = 10692, name = "Cerebral Cortex Compound", icon = "Interface\\Icons\\INV_Potion_32", duration = 3600},
    [9264]  = {buffID = 11474, name = "Elixir of Shadow Power", icon = "Interface\\Icons\\INV_Potion_46", duration = 1800},
    [51718] = {buffID = 22731, name = "Juicy Striped Melon", icon = "Interface\\Icons\\INV_Misc_Food_22", duration = 900},
    [13511] = {buffID = 17627, name = "Flask of Distilled Wisdom", icon = "Interface\\Icons\\INV_Potion_97", duration = 7200},
    [60977] = {buffID = 57043, name = "Danonzo's Tel'Abim Delight", icon = "Interface\\Icons\\INV_Drink_17", duration = 900},
    [12458] = {buffID = 16327, name = "Juju Guile", icon = "Interface\\Icons\\INV_Misc_MonsterScales_13", duration = 1800},
    [13931] = {buffID = 18194, name = "Nightfin Soup", icon = "Interface\\Icons\\INV_Drink_17", duration = 600},
    -- Protection Potions (all marked as On Use)
    [13461] = {buffID = 17549, name = "Greater Arcane Protection Potion", icon = "Interface\\Icons\\INV_Potion_102", duration = 3600, isOnUse = true},
    [13456] = {buffID = 17544, name = "Greater Frost Protection Potion", icon = "Interface\\Icons\\INV_Potion_20", duration = 3600, isOnUse = true},
    [6050]  = {buffID = 7239, name = "Frost Protection Potion", icon = "Interface\\Icons\\INV_Potion_13", duration = 3600, isOnUse = true},
    [13457] = {buffID = 17543, name = "Greater Fire Protection Potion", icon = "Interface\\Icons\\INV_Potion_117", duration = 3600, isOnUse = true},
    [6049]  = {buffID = 7233, name = "Fire Protection Potion", icon = "Interface\\Icons\\INV_Potion_16", duration = 3600, isOnUse = true},
    [13460] = {buffID = 17545, name = "Greater Holy Protection Potion", icon = "Interface\\Icons\\INV_Potion_09", duration = 3600, isOnUse = true},
    [6051]  = {buffID = 7245, name = "Holy Protection Potion", icon = "Interface\\Icons\\INV_Potion_09", duration = 3600, isOnUse = true},
    [13458] = {buffID = 17546, name = "Greater Nature Protection Potion", icon = "Interface\\Icons\\INV_Potion_22", duration = 3600, isOnUse = true},
    [6052]  = {buffID = 7254, name = "Nature Protection Potion", icon = "Interface\\Icons\\INV_Potion_06", duration = 3600, isOnUse = true},
    [13459] = {buffID = 17548, name = "Greater Shadow Protection Potion", icon = "Interface\\Icons\\INV_Potion_23", duration = 3600, isOnUse = true},
    [6048]  = {buffID = 7242, name = "Shadow Protection Potion", icon = "Interface\\Icons\\INV_Potion_44", duration = 3600, isOnUse = true},
    [9036]  = {buffID = 11364, name = "Magic Resistance Potion", icon = "Interface\\Icons\\INV_Potion_16", duration = 180, isOnUse = true},
    [13455] = {buffID = 17540, name = "Greater Stoneshield Potion", icon = "Interface\\Icons\\INV_Potion_69", duration = 120, isOnUse = true},
    [4623]  = {buffID = 4941, name = "Lesser Stoneshield Potion", icon = "Interface\\Icons\\INV_Potion_67", duration = 90, isOnUse = true},
    -- Uncategorized
    [20081] = {buffID = 24383, name = "Swiftness of Zanza", icon = "Interface\\Icons\\INV_Potion_31", duration = 7200},
    [61181] = {buffID = 45425, name = "Potion of Quickness", icon = "Interface\\Icons\\INV_Potion_25", duration = 30, isOnUse = true},
    [5634] = {buffID = 6615, name = "Free Action Potion", icon = "Interface\\Icons\\INV_Potion_04", duration = 30, isOnUse = true},
    [3386] = {buffID = 26677, name = "Elixir of Poison Resistance", icon = "Interface\\Icons\\INV_Potion_12", duration = 1},
    [61675] = {buffID = nil, name = "Nordanaar Herbal Tea", icon = "Interface\\Icons\\INV_Drink_Waterskin_03", duration = 0, isOnUse = true, isInstantEffect = true},
    [9030] = {buffID = 11359, name = "Restorative Potion", icon = "Interface\\Icons\\INV_Potion_118", duration = 30, isOnUse = true},
    [3387] = {buffID = 3169, name = "Limited Invulnerability Potion", icon = "Interface\\Icons\\INV_Potion_121", duration = 6, isOnUse = true},
    [12217] = {buffID = 15852, name = "Dragonbreath Chili", icon = "Interface\\Icons\\INV_Drink_23", duration = 600},

}

-- Saved variables to persist across sessions
RaidingConsumesDB = RaidingConsumesDB or {
    consumablesSelected = {}, -- Table of itemID -> buffID
    threshold = 120,          -- Default reapplication threshold in seconds
    PosX = 200,               -- GUI X position
    PosY = -200,              -- GUI Y position
    showOnUseOnly = false,    -- Filter to show only On-Use consumables
    verticalLayout = false,   -- Use vertical layout (top to bottom) instead of horizontal
    separateConsumes = false, -- NEW: Use separate windows for on-use and regular consumables
    onUsePosX = 200,          -- NEW: On-use window X position
    onUsePosY = -200,         -- NEW: On-use window Y position
    regularPosX = 200,        -- NEW: Regular consumables window X position
    regularPosY = -300        -- NEW: Regular consumables window Y position
}

-- ### Helper Functions
-- (Existing helpers unchanged: strsplit, string.trim, HasBuff, HasItem, FindAndUseItem, IsEatingOrDrinking)

-- **Split strings by a delimiter**
local function strsplit(delim, str)
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local lastPos = 1
    for part, pos in string.gfind(str, pat) do
        table.insert(result, part)
        lastPos = pos
    end
    table.insert(result, string.sub(str, lastPos))
    return result
end

-- **Custom string.trim function for compatibility**
function string.trim(s)
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

-- **Check if a buff is active and has more than the threshold time left**
local function HasBuff(buffID, threshold)
    for i = 0, 31 do
        local id = GetPlayerBuff(i, "HELPFUL")
        if id > -1 then
            local buff = GetPlayerBuffID(i)
            if buff == buffID then
                local timeleft = GetPlayerBuffTimeLeft(id)
                if timeleft > threshold then
                    return true
                end
            end
        end
    end
    return false
end

-- **Check if a specific buff exists (regardless of time left)**
local function HasBuffActive(buffID)
    for i = 0, 31 do
        local id = GetPlayerBuff(i, "HELPFUL")
        if id > -1 then
            local buff = GetPlayerBuffID(i)
            if buff == buffID then
                return true
            end
        end
    end
    return false
end

-- Check if an item is in your bags
local function HasItem(itemID)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local startPos, endPos, foundID = string.find(itemLink, "Hitem:(%d+)")
                if foundID and tonumber(foundID) == itemID then
                    return true
                end
            end
        end
    end
    return false
end

-- Find and use an item from your bags
local function FindAndUseItem(itemID)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local startPos, endPos, foundID = string.find(itemLink, "Hitem:(%d+)")
                if foundID and tonumber(foundID) == itemID then
                    UseContainerItem(bag, slot)
                    return true
                end
            end
        end
    end
    return false
end

-- Local helper to detect if we have the "eating/drinking" buff
local function IsEatingOrDrinking()
    for i = 1, 32 do
        local texture = UnitBuff("player", i)
        if not texture then
            break
        end
        -- Check for known textures
        if texture == "Interface\\Icons\\INV_Misc_Fork&Knife" 
        or texture == "Interface\\Icons\\INV_Drink_07" then
            return true
        end
    end
    return false
end

-- Function to check if an item has individual cooldown management
local function HasIndividualCooldown(itemID)
    -- Juju items (all start with 124 except 12451 which is Juju Power - not on individual cooldown)
    if itemID == 12450 or itemID == 12455 or itemID == 12457 or itemID == 12458 or itemID == 12459 or itemID == 12460 then
        return true, JUJU_COOLDOWN
    end
    -- Nordanaar Herbal Tea
    if itemID == 61675 then
        return true, NORDANAAR_COOLDOWN
    end
    return false, 0
end

-- Function to get individual cooldown remaining for an item
local function GetIndividualCooldown(itemID)
    local hasIndividual, cooldownDuration = HasIndividualCooldown(itemID)
    if not hasIndividual then
        return 0
    end
    
    local lastUsed = individualCooldowns[itemID] or 0
    local currentTime = GetTime()
    return math.max(0, cooldownDuration - (currentTime - lastUsed))
end
local function CheckPendingOnUseItems()
    local currentTime = GetTime()
    
    for itemID, useTime in pairs(pendingOnUseItems) do
        local data = consumablesDB[itemID]
        if data and data.isOnUse then
            local buffID = RaidingConsumesDB.consumablesSelected[itemID]
            
            if buffID and HasBuffActive(buffID) then
                -- Buff appeared! Start the appropriate cooldown
                local hasIndividual, _ = HasIndividualCooldown(itemID)
                if hasIndividual then
                    individualCooldowns[itemID] = useTime
                else
                    lastOnUseTime = useTime
                end
                pendingOnUseItems[itemID] = nil -- Remove from pending
            elseif (currentTime - useTime) > PENDING_TIMEOUT then
                -- Timeout reached, item use failed - remove from pending without starting cooldown
                pendingOnUseItems[itemID] = nil
            end
        end
    end
end

-- ### Core Functionality

-- Create the addon frame and GUI
local RC = CreateFrame("Frame")
RC.ConfigFrame = CreateFrame("Frame", nil, UIParent)
RC.OnUseFrame = CreateFrame("Frame", nil, UIParent) -- NEW: Separate frame for on-use consumables
RC.RegularFrame = CreateFrame("Frame", nil, UIParent) -- NEW: Separate frame for regular consumables
RC.buttons = {}
RC.onUseButtons = {} -- NEW: Buttons for on-use frame
RC.regularButtons = {} -- NEW: Buttons for regular frame

RC.ConfigFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
RC.ConfigFrame:RegisterEvent("UNIT_COMBAT")
RC.ConfigFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
RC.ConfigFrame:SetScript("OnEvent", function()
    if event == "PLAYER_AURAS_CHANGED" then
        CheckPendingOnUseItems() -- Check if any pending items got their buffs
        RC:UpdateGUI()
    elseif event == "UNIT_COMBAT" then
        -- Handle Nordanaar Herbal Tea healing confirmation
        if arg1 == "player" and arg2 == "HEAL" and arg4 then
            RC:HandleTeaHealing(arg4)
        end
    elseif event == "CHAT_MSG_COMBAT_SELF_HITS" then
        -- Alternative method: parse chat message for tea healing
        if arg1 and string.find(arg1, "Your Tea heals you for") then
            RC:HandleTeaHealingFromChat(arg1)
        end
    end
end)

-- Function to toggle layout for a specific frame
local function ToggleFrameLayout(frame)
    if RaidingConsumesDB.separateConsumes then
        -- In separate windows mode, toggle individual layouts
        if frame == RC.OnUseFrame then
            RaidingConsumesDB.onUseVerticalLayout = not RaidingConsumesDB.onUseVerticalLayout
            local layoutText = RaidingConsumesDB.onUseVerticalLayout and "vertical" or "horizontal"
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r On-use window layout changed to " .. layoutText .. ".")
        elseif frame == RC.RegularFrame then
            RaidingConsumesDB.regularVerticalLayout = not RaidingConsumesDB.regularVerticalLayout
            local layoutText = RaidingConsumesDB.regularVerticalLayout and "vertical" or "horizontal"
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Regular window layout changed to " .. layoutText .. ".")
        end
    else
        -- In single window mode, toggle main layout
        RaidingConsumesDB.verticalLayout = not RaidingConsumesDB.verticalLayout
        local layoutText = RaidingConsumesDB.verticalLayout and "vertical" or "horizontal"
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Main window layout changed to " .. layoutText .. ".")
    end
    RC:UpdateGUI()
end

-- Setup function for frames
local function SetupFrame(frame, posX, posY)
    local backdrop = {
        bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 5, top = 3, bottom = 5 }
    }
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetWidth(100)
    frame:SetHeight(48)
    frame:SetMovable(1)
    frame:EnableMouse(1)
    frame:RegisterForDrag("LeftButton")
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", posX, posY)
    
    -- Add right-click functionality for layout switching
    frame:SetScript("OnMouseDown", function()
        if arg1 == "RightButton" then
            ToggleFrameLayout(this)
        end
    end)
    
    frame:Hide()
end

-- Setup the main frame
SetupFrame(RC.ConfigFrame, RaidingConsumesDB.PosX, RaidingConsumesDB.PosY)
RC.ConfigFrame:SetScript("OnDragStart", function() RC.ConfigFrame:StartMoving() end)
RC.ConfigFrame:SetScript("OnDragStop", function()
    RC.ConfigFrame:StopMovingOrSizing()
    _, _, _, RaidingConsumesDB.PosX, RaidingConsumesDB.PosY = RC.ConfigFrame:GetPoint()
end)

-- Setup the on-use frame
SetupFrame(RC.OnUseFrame, RaidingConsumesDB.onUsePosX, RaidingConsumesDB.onUsePosY)
RC.OnUseFrame:SetScript("OnDragStart", function() RC.OnUseFrame:StartMoving() end)
RC.OnUseFrame:SetScript("OnDragStop", function()
    RC.OnUseFrame:StopMovingOrSizing()
    _, _, _, RaidingConsumesDB.onUsePosX, RaidingConsumesDB.onUsePosY = RC.OnUseFrame:GetPoint()
end)

-- Setup the regular frame
SetupFrame(RC.RegularFrame, RaidingConsumesDB.regularPosX, RaidingConsumesDB.regularPosY)
RC.RegularFrame:SetScript("OnDragStart", function() RC.RegularFrame:StartMoving() end)
RC.RegularFrame:SetScript("OnDragStop", function()
    RC.RegularFrame:StopMovingOrSizing()
    _, _, _, RaidingConsumesDB.regularPosX, RaidingConsumesDB.regularPosY = RC.RegularFrame:GetPoint()
end)

-- Add this function to count items in bags
local function CountItemInBags(itemID)
    local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local startPos, endPos, foundID = string.find(itemLink, "Hitem:(%d+)")
                if foundID and tonumber(foundID) == itemID then
                    local _, stackCount = GetContainerItemInfo(bag, slot)
                    count = count + (stackCount or 1)
                end
            end
        end
    end
    return count
end

-- Function to create buttons for a specific frame
local function CreateButtonsForFrame(frame, buttonTable, maxButtons)
    for i = 1, maxButtons do
        local button = CreateFrame("Button", nil, frame)
        button:SetWidth(32)
        button:SetHeight(32)
        button:Hide()

        button.timerText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.timerText:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.timerText:SetText("")

        button.countText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.countText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        button.countText:SetTextColor(1, 1, 1)
        button.countText:SetText("")

        button.overlay = button:CreateTexture(nil, "OVERLAY")
        button.overlay:SetAllPoints()
        button.overlay:SetTexture(0, 1, 0, 0.3)
        button.overlay:Hide()

        table.insert(buttonTable, button)
    end
end

-- Create buttons for all frames
CreateButtonsForFrame(RC.ConfigFrame, RC.buttons, 25) -- Extended to 25
CreateButtonsForFrame(RC.OnUseFrame, RC.onUseButtons, 25)
CreateButtonsForFrame(RC.RegularFrame, RC.regularButtons, 25)

-- Handle Nordanaar Herbal Tea healing confirmation
function RC:HandleTeaHealing(healAmount)
    -- Check if we have a pending Nordanaar Herbal Tea
    local teaItemID = 61675
    if pendingOnUseItems[teaItemID] then
        -- Tea healing detected, start individual cooldown
        individualCooldowns[teaItemID] = pendingOnUseItems[teaItemID]
        pendingOnUseItems[teaItemID] = nil
    end
end

-- Alternative handler for chat message parsing
function RC:HandleTeaHealingFromChat(message)
    -- Parse heal amount from message like "Your Tea heals you for 859."
    local healAmount = string.match(message, "Your Tea heals you for (%d+)")
    if healAmount then
        self:HandleTeaHealing(tonumber(healAmount))
    end
end

-- ##################################################
-- Function to update timer text on each button
-- ##################################################
function RC:UpdateTimers()
    local currentTime = GetTime()
    local threshold = RaidingConsumesDB.threshold or 120
    local sharedCooldown = math.max(0, ON_USE_COOLDOWN - (currentTime - lastOnUseTime))

    -- Function to update buttons in a specific table
    local function UpdateButtonTable(buttonTable)
        for i, button in ipairs(buttonTable) do
            if button:IsShown() and button.itemID then
                local itemID = button.itemID
                local data = consumablesDB[itemID]
                local buffID = RaidingConsumesDB.consumablesSelected[itemID]
                local foundTimeLeft = 0

                -- Update item count
                local itemCount = CountItemInBags(itemID)
                button.countText:SetText(itemCount)
                
                -- Color the count based on quantity
                if itemCount == 0 then
                    button.countText:SetTextColor(1, 0, 0) -- Red for zero items
                elseif itemCount <= 3 then
                    button.countText:SetTextColor(1, 0.5, 0) -- Orange for low items
                else
                    button.countText:SetTextColor(1, 1, 1) -- White for sufficient items
                end

                -- Check for active buff
                if buffID then
                    for auraIndex = 0, 31 do
                        local buffIndex = GetPlayerBuff(auraIndex, "HELPFUL")
                        if buffIndex > -1 then
                            local checkBuffID = GetPlayerBuffID(auraIndex)
                            if checkBuffID == buffID then
                                foundTimeLeft = GetPlayerBuffTimeLeft(buffIndex)
                                break
                            end
                        end
                    end
                end

                if data.isOnUse then
                    -- Check if this item is pending (waiting for buff confirmation)
                    local isPending = pendingOnUseItems[itemID] ~= nil
                    
                    -- Check for individual cooldown or shared cooldown
                    local hasIndividual, _ = HasIndividualCooldown(itemID)
                    local relevantCooldown = 0
                    if hasIndividual then
                        relevantCooldown = GetIndividualCooldown(itemID)
                    else
                        relevantCooldown = sharedCooldown
                    end
                    
                    -- Special handling for instant effect items (no buff to show)
                    if data.isInstantEffect then
                        if isPending then
                            -- Item was used but effect not detected yet: yellow overlay, show "WAIT"
                            button:SetAlpha(1.0)
                            button.overlay:Show()
                            button.overlay:SetTexture(1, 1, 0, 0.3) -- Yellow overlay
                            button.timerText:SetText("WAIT")
                            button:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8) -- Slightly dimmed
                        elseif relevantCooldown > 0 then
                            -- On cooldown: red overlay, show cooldown timer
                            button:SetAlpha(1.0)
                            button.overlay:Show()
                            button.overlay:SetTexture(1, 0, 0, 0.3) -- Red overlay
                            local totalSeconds = math.floor(relevantCooldown)
                            local mins = math.floor(totalSeconds / 60)
                            local secs = totalSeconds - (mins * 60)
                            button.timerText:SetText(string.format("%d:%02d", mins, secs))
                            button:GetNormalTexture():SetVertexColor(0.5, 0.5, 0.5) -- Dimmed color
                        else
                            -- Ready to use: full alpha, no overlay, no timer
                            button:SetAlpha(1.0)
                            button.overlay:Hide()
                            button.timerText:SetText("")
                            button:GetNormalTexture():SetVertexColor(1, 1, 1) -- Normal color
                        end
                    elseif foundTimeLeft > 0 then
                        -- Buff is active: full alpha, green overlay, show buff timer
                        button:SetAlpha(1.0)
                        button.overlay:Show()
                        button.overlay:SetTexture(0, 1, 0, 0.3) -- Green overlay
                        local totalSeconds = math.floor(foundTimeLeft)
                        local mins = math.floor(totalSeconds / 60)
                        local secs = totalSeconds - (mins * 60)
                        button.timerText:SetText(string.format("%d:%02d", mins, secs))
                        button:GetNormalTexture():SetVertexColor(1, 1, 1) -- Normal color
                    elseif isPending then
                        -- Item was used but buff not detected yet: yellow overlay, show "WAIT"
                        button:SetAlpha(1.0)
                        button.overlay:Show()
                        button.overlay:SetTexture(1, 1, 0, 0.3) -- Yellow overlay
                        button.timerText:SetText("WAIT")
                        button:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8) -- Slightly dimmed
                    elseif relevantCooldown > 0 then
                        -- On cooldown but no buff: red overlay, show cooldown timer
                        button:SetAlpha(1.0)
                        button.overlay:Show()
                        button.overlay:SetTexture(1, 0, 0, 0.3) -- Red overlay
                        local totalSeconds = math.floor(relevantCooldown)
                        local mins = math.floor(totalSeconds / 60)
                        local secs = totalSeconds - (mins * 60)
                        button.timerText:SetText(string.format("%d:%02d", mins, secs))
                        button:GetNormalTexture():SetVertexColor(0.5, 0.5, 0.5) -- Dimmed color
                    else
                        -- Ready to use: full alpha, no overlay, no timer
                        button:SetAlpha(1.0)
                        button.overlay:Hide()
                        button.timerText:SetText("")
                        button:GetNormalTexture():SetVertexColor(1, 1, 1) -- Normal color
                    end
                else
                    -- Regular consumable (not on-use)
                    if foundTimeLeft > 0 then
                        -- Buff active: full alpha, green overlay, show timer
                        button:SetAlpha(1.0)
                        button.overlay:Show()
                        button.overlay:SetTexture(0, 1, 0, 0.3) -- Green overlay
                        local totalSeconds = math.floor(foundTimeLeft)
                        local mins = math.floor(totalSeconds / 60)
                        local secs = totalSeconds - (mins * 60)
                        button.timerText:SetText(string.format("%d:%02d", mins, secs))
                        if totalSeconds <= threshold then
                            button:GetNormalTexture():SetVertexColor(1, 0.5, 0) -- Orange tint when low
                        else
                            button:GetNormalTexture():SetVertexColor(1, 1, 1) -- Normal color
                        end
                    else
                        -- No buff active: dimmed, no overlay, no timer
                        button:SetAlpha(0.3)
                        button.overlay:Hide()
                        button.timerText:SetText("")
                        button:GetNormalTexture():SetVertexColor(1, 1, 1) -- Normal color
                    end
                end
            else
                -- Hidden button or no itemID
                if button.timerText then
                    button.timerText:SetText("")
                end
                if button.countText then
                    button.countText:SetText("")
                end
                if button.overlay then
                    button.overlay:Hide()
                end
            end
        end
    end
    
    -- Update all button tables
    UpdateButtonTable(self.buttons)
    UpdateButtonTable(self.onUseButtons)
    UpdateButtonTable(self.regularButtons)
end

-- Function to update the GUI
-- Modify the UpdateGUI function to update counts
function RC:UpdateGUI()
    if RaidingConsumesDB.separateConsumes then
        self:UpdateSeparateGUI()
    else
        self:UpdateSingleGUI()
    end
end

-- Update single GUI (original functionality)
function RC:UpdateSingleGUI()
    -- Hide separate frames
    RC.OnUseFrame:Hide()
    RC.RegularFrame:Hide()
    
    local selected = {}
    for itemID, _ in pairs(RaidingConsumesDB.consumablesSelected) do
        -- Apply filter if showOnUseOnly is enabled
        if RaidingConsumesDB.showOnUseOnly then
            local data = consumablesDB[itemID]
            if data and data.isOnUse then
                table.insert(selected, itemID)
            end
        else
            table.insert(selected, itemID)
        end
    end
    table.sort(selected, function(a, b)
        return consumablesDB[a].name < consumablesDB[b].name
    end)
    
    local numButtons = 0
    for _ in pairs(selected) do numButtons = numButtons + 1 end
    
    self:UpdateFrameButtons(RC.ConfigFrame, RC.buttons, selected, numButtons)
    
    -- Show main frame if we have buttons
    if numButtons > 0 then
        RC.ConfigFrame:Show()
    else
        RC.ConfigFrame:Hide()
    end
end

-- Update separate GUI (new functionality)
function RC:UpdateSeparateGUI()
    -- Hide main frame
    RC.ConfigFrame:Hide()
    
    local onUseItems = {}
    local regularItems = {}
    
    for itemID, _ in pairs(RaidingConsumesDB.consumablesSelected) do
        local data = consumablesDB[itemID]
        if data then
            if data.isOnUse then
                table.insert(onUseItems, itemID)
            else
                table.insert(regularItems, itemID)
            end
        end
    end
    
    -- Sort both lists
    table.sort(onUseItems, function(a, b)
        return consumablesDB[a].name < consumablesDB[b].name
    end)
    table.sort(regularItems, function(a, b)
        return consumablesDB[a].name < consumablesDB[b].name
    end)
    
    local onUseCount = 0
    for _ in pairs(onUseItems) do onUseCount = onUseCount + 1 end
    
    local regularCount = 0
    for _ in pairs(regularItems) do regularCount = regularCount + 1 end
    
    -- Update both frames
    self:UpdateFrameButtons(RC.OnUseFrame, RC.onUseButtons, onUseItems, onUseCount)
    self:UpdateFrameButtons(RC.RegularFrame, RC.regularButtons, regularItems, regularCount)
    
    -- Show frames if they have buttons
    if onUseCount > 0 then
        RC.OnUseFrame:Show()
    else
        RC.OnUseFrame:Hide()
    end
    
    if regularCount > 0 then
        RC.RegularFrame:Show()
    else
        RC.RegularFrame:Hide()
    end
end

-- Common function to update buttons for any frame
function RC:UpdateFrameButtons(frame, buttons, itemList, numButtons)
    local buttonSize = 32
    local spacing = 5
    local padding = 5
    
    -- Determine which layout to use based on frame and mode
    local useVerticalLayout = RaidingConsumesDB.verticalLayout -- Default for single window mode
    
    if RaidingConsumesDB.separateConsumes then
        -- In separate windows mode, use individual layout settings
        if frame == RC.OnUseFrame then
            useVerticalLayout = RaidingConsumesDB.onUseVerticalLayout
        elseif frame == RC.RegularFrame then
            useVerticalLayout = RaidingConsumesDB.regularVerticalLayout
        end
    end
    
    for i = 1, 25 do -- Extended to 25
        local button = buttons[i]
        if i <= numButtons then
            local itemID = itemList[i]
            local icon = consumablesDB[itemID].icon
            button:SetNormalTexture(icon)
            button.itemID = itemID
            
            -- Count items and update the count text
            local itemCount = CountItemInBags(itemID)
            button.countText:SetText(itemCount)
            
            -- Color the count based on quantity
            if itemCount == 0 then
                button.countText:SetTextColor(1, 0, 0) -- Red for zero items
            elseif itemCount <= 3 then
                button.countText:SetTextColor(1, 0.5, 0) -- Orange for low items
            else
                button.countText:SetTextColor(1, 1, 1) -- White for sufficient items
            end
            
            -- OnClick to use consumable
            button:SetScript("OnClick", function()
                RC:UseConsumable(itemID)
            end)
            
            -- Tooltip handling
            button:SetScript("OnEnter", function()
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("item:" .. itemID)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            
            -- Position the button based on layout orientation
            button:ClearAllPoints()
            if useVerticalLayout then
                -- Vertical layout: buttons stack top to bottom
                local currentY = -padding - ((i - 1) * (buttonSize + spacing))
                button:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, currentY)
            else
                -- Horizontal layout: buttons go left to right
                local currentX = padding + ((i - 1) * (buttonSize + spacing))
                button:SetPoint("TOPLEFT", frame, "TOPLEFT", currentX, -padding)
            end
            button:Show()
        else
            button:Hide()
        end
    end
    
    -- Adjust frame dimensions based on layout orientation
    if numButtons > 0 then
        if useVerticalLayout then
            -- Vertical layout: fixed width, height grows with buttons
            frame:SetWidth(buttonSize + (padding * 2))
            frame:SetHeight((numButtons * (buttonSize + spacing)) - spacing + (padding * 2))
        else
            -- Horizontal layout: width grows with buttons, fixed height
            frame:SetWidth((numButtons * (buttonSize + spacing)) - spacing + (padding * 2))
            frame:SetHeight(buttonSize + (padding * 2))
        end
    else
        frame:SetWidth(100) -- Default empty width
        frame:SetHeight(48)  -- Default empty height
    end
end


-- Function to use a specific consumable
function RC:UseConsumable(itemID)
    if IsEatingOrDrinking() then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r You are currently eating or drinking; wait to apply new buffs.")
        return
    end

    local data = consumablesDB[itemID]
    if not data then return end

    if data.isOnUse then
        -- Check for individual or shared cooldown
        local hasIndividual, cooldownDuration = HasIndividualCooldown(itemID)
        local relevantCooldown = 0
        
        if hasIndividual then
            relevantCooldown = GetIndividualCooldown(itemID)
        else
            local currentTime = GetTime()
            relevantCooldown = math.max(0, ON_USE_COOLDOWN - (currentTime - lastOnUseTime))
        end
        
        if relevantCooldown > 0 then
            return
        end
        
        -- Allow retrying even during pending state (for spamming during encounters)
        
        if HasItem(itemID) then
            -- For instant effect items, don't check for existing buffs
            if data.isInstantEffect then
                FindAndUseItem(itemID)
                -- Mark as pending for combat event confirmation
                pendingOnUseItems[itemID] = GetTime()
            else
                -- Check if we already have the buff for regular consumables
                local buffID = RaidingConsumesDB.consumablesSelected[itemID]
                if buffID and HasBuffActive(buffID) then
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r " .. data.name .. " buff is already active.")
                    return
                end
                
                FindAndUseItem(itemID)
                -- Mark as pending instead of immediately starting cooldown
                pendingOnUseItems[itemID] = GetTime()
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r You need to restock on " .. data.name)
        end
    else
        -- For regular consumables, check buff status
        local buffID = RaidingConsumesDB.consumablesSelected[itemID]
        if buffID and not HasBuff(buffID, RaidingConsumesDB.threshold) then
            if HasItem(itemID) then
                FindAndUseItem(itemID)
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r You need to restock on " .. data.name)
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Buff is still active or not selected.")
        end
    end
end

-- Apply selected consumables (unchanged)
local function UseConsumables()
    if IsEatingOrDrinking() then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r You are currently eating or drinking; wait to apply new buffs.")
        return
    end
    
    local missingItems = {}
    for itemID, buffID in pairs(RaidingConsumesDB.consumablesSelected) do
        local data = consumablesDB[itemID]
        if not data.isOnUse then
            if not HasBuff(buffID, RaidingConsumesDB.threshold) then
                if HasItem(itemID) then
                    FindAndUseItem(itemID)
                else
                    table.insert(missingItems, data.name)
                end
            end
        end
    end
    
    if table.getn(missingItems) > 0 then
        local currentTime = GetTime()
        if currentTime - lastMessageTime >= COOLDOWN_TIME then
            local message = "You need to restock on "
            local count = table.getn(missingItems)
            if count == 1 then
                message = message .. missingItems[1]
            elseif count == 2 then
                message = message .. missingItems[1] .. " and " .. missingItems[2]
            else
                message = message .. table.concat(missingItems, ", ", 1, count - 1) .. ", and " .. missingItems[count]
            end
            print(message)
            lastMessageTime = currentTime
        end
    end
end

-- Modified slash command handler
local function RaidingConsumes_SlashCommand(msg)
    if not msg or msg == "" then
        if RaidingConsumesDB.separateConsumes then
            -- Toggle visibility for separate windows
            if RC.OnUseFrame:IsShown() or RC.RegularFrame:IsShown() then
                RC.OnUseFrame:Hide()
                RC.RegularFrame:Hide()
            else
                RC:UpdateGUI()
            end
        else
            -- Toggle visibility for single window
            if RC.ConfigFrame:IsShown() then
                RC.ConfigFrame:Hide()
            else
                RC:UpdateGUI()
                RC.ConfigFrame:Show()
            end
        end
        return
    end
    
    local lowerMsg = string.lower(msg)
    local args = strsplit(" ", lowerMsg)
    local cmd = args[1]
    table.remove(args, 1)

    if cmd == "list" then
        local selected = {}
        for itemID, _ in pairs(RaidingConsumesDB.consumablesSelected) do
            local data = consumablesDB[itemID]
            if data then
                table.insert(selected, data.name)
            end
        end
        if table.getn(selected) == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r No consumables selected.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Selected consumables: " .. table.concat(selected, ", "))
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Current reapplication threshold: " .. (RaidingConsumesDB.threshold or 0) .. " seconds.")
            if RaidingConsumesDB.separateConsumes then
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI Mode: Separate windows for on-use and regular consumables.")
                local onUseLayout = RaidingConsumesDB.onUseVerticalLayout and "vertical" or "horizontal"
                local regularLayout = RaidingConsumesDB.regularVerticalLayout and "vertical" or "horizontal"
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r On-use window layout: " .. onUseLayout .. ", Regular window layout: " .. regularLayout .. ".")
            elseif RaidingConsumesDB.showOnUseOnly then
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI Filter: Showing only On-Use consumables.")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI Filter: Showing all selected consumables.")
            end
            if not RaidingConsumesDB.separateConsumes then
                if RaidingConsumesDB.verticalLayout then
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI Layout: Vertical (top to bottom).")
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI Layout: Horizontal (left to right).")
                end
            end
        end

    elseif cmd == "threshold" then
        local seconds = tonumber(args[1])
        if seconds and seconds > 0 then
            RaidingConsumesDB.threshold = seconds
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Reapplication threshold set to " .. seconds .. " seconds.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Usage: /rc threshold [seconds]")
        end

    elseif cmd == "onuseonly" then
        -- Disable separate consumes if it's enabled
        if RaidingConsumesDB.separateConsumes then
            RaidingConsumesDB.separateConsumes = false
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Separate windows disabled.")
        end
        
        RaidingConsumesDB.showOnUseOnly = not RaidingConsumesDB.showOnUseOnly
        if RaidingConsumesDB.showOnUseOnly then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI will now show only On-Use consumables.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI will now show all selected consumables.")
        end
        RC:UpdateGUI()

    elseif cmd == "separateconsumes" then
        -- Disable onuseonly if it's enabled
        if RaidingConsumesDB.showOnUseOnly then
            RaidingConsumesDB.showOnUseOnly = false
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r On-use only filter disabled.")
        end
        
        RaidingConsumesDB.separateConsumes = not RaidingConsumesDB.separateConsumes
        if RaidingConsumesDB.separateConsumes then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Separate windows enabled: on-use and regular consumables will have their own windows.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Separate windows disabled: using single window mode.")
        end
        RC:UpdateGUI()

    elseif cmd == "vertical" then
        if RaidingConsumesDB.separateConsumes then
            -- In separate mode, affect both windows
            RaidingConsumesDB.onUseVerticalLayout = true
            RaidingConsumesDB.regularVerticalLayout = true
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Both windows changed to vertical layout (top to bottom).")
        else
            RaidingConsumesDB.verticalLayout = true
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI layout changed to vertical (top to bottom).")
        end
        RC:UpdateGUI()

    elseif cmd == "horizontal" then
        if RaidingConsumesDB.separateConsumes then
            -- In separate mode, affect both windows
            RaidingConsumesDB.onUseVerticalLayout = false
            RaidingConsumesDB.regularVerticalLayout = false
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Both windows changed to horizontal layout (left to right).")
        else
            RaidingConsumesDB.verticalLayout = false
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r GUI layout changed to horizontal (left to right).")
        end
        RC:UpdateGUI()

    elseif cmd == "onusehorizontal" then
        RaidingConsumesDB.onUseVerticalLayout = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r On-use window layout changed to horizontal (left to right).")
        RC:UpdateGUI()

    elseif cmd == "onusevertical" then
        RaidingConsumesDB.onUseVerticalLayout = true
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r On-use window layout changed to vertical (top to bottom).")
        RC:UpdateGUI()

    elseif cmd == "regularhorizontal" then
        RaidingConsumesDB.regularVerticalLayout = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Regular consumables window layout changed to horizontal (left to right).")
        RC:UpdateGUI()

    elseif cmd == "regularvertical" then
        RaidingConsumesDB.regularVerticalLayout = true
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Regular consumables window layout changed to vertical (top to bottom).")
        RC:UpdateGUI()

    elseif cmd == "reset" then
        RaidingConsumesDB.consumablesSelected = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Consumables selection has been reset.")
        RC:UpdateGUI()

    elseif cmd == "remove" then
        local removeList = table.concat(args, " ")
        if removeList == "" then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Please specify consumables to remove, e.g., /rc remove Juju Power")
            return
        end
        local input = strsplit(",", removeList)
        for _, name in pairs(input) do
            name = string.trim(name)
            local lowerName = string.lower(name)
            local itemID = nil
            for id, data in pairs(consumablesDB) do
                if string.lower(data.name) == lowerName then
                    itemID = id
                    break
                end
            end
            if itemID then
                if RaidingConsumesDB.consumablesSelected[itemID] then
                    RaidingConsumesDB.consumablesSelected[itemID] = nil
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Removed '" .. consumablesDB[itemID].name .. "' from your selected consumables.")
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r '" .. consumablesDB[itemID].name .. "' is not in your selected consumables.")
                end
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Consumable '" .. name .. "' not found in database.")
            end
        end
        RC:UpdateGUI()

    elseif cmd == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Available commands:")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc|r - Toggle GUI visibility")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc list|r - Show selected consumables and settings")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc threshold [seconds]|r - Set reapplication threshold")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc onuseonly|r - Toggle showing only On-Use consumables in GUI")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc separateconsumes|r - Toggle separate windows for on-use and regular consumables")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc vertical|r - Set GUI to vertical layout (top to bottom)")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc horizontal|r - Set GUI to horizontal layout (left to right)")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc onusevertical|r - Set on-use window to vertical layout")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc onusehorizontal|r - Set on-use window to horizontal layout")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc regularvertical|r - Set regular window to vertical layout")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc regularhorizontal|r - Set regular window to horizontal layout")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc remove [consumable]|r - Remove consumable from selection")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc reset|r - Clear all selected consumables")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/rc [consumable names]|r - Add consumables to selection")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Right-click on any window to toggle its layout!")

    else
        local input = strsplit(",", msg)
        local anyFound = false

        for _, name in pairs(input) do
            name = string.trim(name)
            local nameLower = string.lower(name)
            local itemID = nil
            for dbID, data in pairs(consumablesDB) do
                if string.lower(data.name) == nameLower then
                    itemID = dbID
                    break
                end
            end
            if itemID then
                RaidingConsumesDB.consumablesSelected[itemID] = consumablesDB[itemID].buffID
                anyFound = true
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Added '" .. consumablesDB[itemID].name .. "' to your selected consumables.")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Consumable '" .. name .. "' not found in database.")
            end
        end

        if anyFound then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Selected consumables updated. Use /rc list to see them.")
            RC:UpdateGUI()
        end
    end
end

-- ### Register Slash Commands
SLASH_RAIDINGCONSUMES1 = "/rc"
SlashCmdList["RAIDINGCONSUMES"] = RaidingConsumes_SlashCommand

SLASH_USECONS1 = "/usecons"
SlashCmdList["USECONS"] = UseConsumables

-- ### Initialization
local function RaidingConsumes_Initialize()
    -- Ensure these exist
    RaidingConsumesDB.threshold = RaidingConsumesDB.threshold or 120
    RaidingConsumesDB.consumablesSelected = RaidingConsumesDB.consumablesSelected or {}
    RaidingConsumesDB.PosX = RaidingConsumesDB.PosX or 200
    RaidingConsumesDB.PosY = RaidingConsumesDB.PosY or -200
    RaidingConsumesDB.showOnUseOnly = RaidingConsumesDB.showOnUseOnly or false
    RaidingConsumesDB.verticalLayout = RaidingConsumesDB.verticalLayout or false
    RaidingConsumesDB.separateConsumes = RaidingConsumesDB.separateConsumes or false -- NEW: Initialize separate windows option
    RaidingConsumesDB.onUsePosX = RaidingConsumesDB.onUsePosX or 200 -- NEW: Initialize on-use window position
    RaidingConsumesDB.onUsePosY = RaidingConsumesDB.onUsePosY or -200
    RaidingConsumesDB.regularPosX = RaidingConsumesDB.regularPosX or 200 -- NEW: Initialize regular window position
    RaidingConsumesDB.regularPosY = RaidingConsumesDB.regularPosY or -300
    RaidingConsumesDB.onUseVerticalLayout = RaidingConsumesDB.onUseVerticalLayout or false -- NEW: On-use window layout
    RaidingConsumesDB.regularVerticalLayout = RaidingConsumesDB.regularVerticalLayout or false -- NEW: Regular window layout
    
    -- Position all frames
    RC.ConfigFrame:ClearAllPoints()
    RC.ConfigFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", RaidingConsumesDB.PosX, RaidingConsumesDB.PosY)
    
    RC.OnUseFrame:ClearAllPoints()
    RC.OnUseFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", RaidingConsumesDB.onUsePosX, RaidingConsumesDB.onUsePosY)
    
    RC.RegularFrame:ClearAllPoints()
    RC.RegularFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", RaidingConsumesDB.regularPosX, RaidingConsumesDB.regularPosY)

    -- Update the GUI
    RC:UpdateGUI()

    -- Show/Hide frames based on mode and content
    local count = 0
    for _ in pairs(RaidingConsumesDB.consumablesSelected) do
        count = count + 1
    end
    
    if count > 0 then
        if RaidingConsumesDB.separateConsumes then
            -- Separate windows mode will be handled by UpdateGUI
        else
            RC.ConfigFrame:Show()
        end
    else
        RC.ConfigFrame:Hide()
        RC.OnUseFrame:Hide()
        RC.RegularFrame:Hide()
    end
end



-- Create a frame to handle addon initialization
local RaidConsumesFrame = CreateFrame("Frame", "RaidConsumesFrame")
RaidConsumesFrame:RegisterEvent("VARIABLES_LOADED")
RaidConsumesFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RaidConsumesFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        RaidingConsumes_Initialize()
        RaidingConsumes_SlashCommand("list")
    elseif event == "PLAYER_ENTERING_WORLD" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r loaded. Please type /rc to show GUI or for help.")
    end
end)

local updateInterval = 1.0  -- Update every 1 second
local lastUpdate = 0

RaidConsumesFrame:SetScript("OnUpdate", function()
    local currentTime = GetTime()
    if (currentTime - lastUpdate) >= updateInterval then
        CheckPendingOnUseItems() -- Check for pending items that may have timed out
        RC:UpdateTimers()
        lastUpdate = currentTime
    end
end)
