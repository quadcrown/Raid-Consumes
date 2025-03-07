-- Global variable for shared On Use cooldown
local lastOnUseTime = 0
local ON_USE_COOLDOWN = 120 -- 2 minutes in seconds

-- Complete database of consumables: itemID -> {buffID, name, icon, duration, isOnUse}
local consumablesDB = {
    -- Melee/ranged power/crit consumables
    [12451] = {buffID = 16323, name = "Juju Power", icon = "Interface\\Icons\\INV_Misc_MonsterScales_11", duration = 3600},
    [9206]  = {buffID = 11405, name = "Elixir of Giants", icon = "Interface\\Icons\\INV_Potion_61", duration = 3600},
    [12820] = {buffID = 17038, name = "Winterfall Firewater", icon = "Interface\\Icons\\INV_Potion_92", duration = 1200},
    [12460] = {buffID = 16329, name = "Juju Might", icon = "Interface\\Icons\\INV_Misc_MonsterScales_07", duration = 600},
    [9224]  = {buffID = 11406, name = "Elixir of Demonslaying", icon = "Interface\\Icons\\INV_Potion_27", duration = 300},
    [13452] = {buffID = 17538, name = "Elixir of the Mongoose", icon = "Interface\\Icons\\INV_Potion_32", duration = 3600},
    [9187]  = {buffID = 11334, name = "Elixir of Greater Agility", icon = "Interface\\Icons\\INV_Potion_94", duration = 3600},
    [8410]  = {buffID = 10667, name = "R.O.I.D.S", icon = "Interface\\Icons\\INV_Stone_15", duration = 3600},
    [8412]  = {buffID = 10669, name = "Ground Scorpok Assay", icon = "Interface\\Icons\\INV_Misc_Dust_02", duration = 1800},
    [5206]  = {buffID = 5665, name = "Bogling Root", icon = "Interface\\Icons\\INV_Misc_Herb_07", duration = 1800},
    [12450] = {buffID = 16322, name = "Juju Flurry", icon = "Interface\\Icons\\INV_Misc_MonsterScales_17", duration = 20, isOnUse = true},
    [60976] = {buffID = 57042, name = "Danonzo's Tel'Abim Surprise", icon = "Interface\\Icons\\INV_Misc_Food_09", duration = 3600},
    [51711] = {buffID = 18192, name = "Sweet Mountain Berry", icon = "Interface\\Icons\\INV_Misc_Food_40", duration = 3600},
    [13928] = {buffID = 18192, name = "Grilled Squid", icon = "Interface\\Icons\\INV_Misc_Food_13", duration = 600},
    [60978] = {buffID = 57046, name = "Danonzo's Tel'Abim Medley", icon = "Interface\\Icons\\INV_Misc_Food_08", duration = 3600},
    [20452] = {buffID = 24799, name = "Smoked Desert Dumplings", icon = "Interface\\Icons\\INV_Misc_Food_64", duration = 900},
    [51720] = {buffID = 24799, name = "Power Mushroom", icon = "Interface\\Icons\\INV_Mushroom_11", duration = 3600},
    [51267] = {buffID = 24799, name = "Spicy Beef Burrito", icon = "Interface\\Icons\\INV_Misc_Food_49", duration = 3600},
    [13442] = {buffID = 17528, name = "Mighty Rage Potion", icon = "Interface\\Icons\\INV_Potion_41", duration = 20, isOnUse = true},
    [5633]  = {buffID = 6613, name = "Great Rage Potion", icon = "Interface\\Icons\\INV_Potion_21", duration = 20, isOnUse = true},
    -- Tank/Defensive/Stamina consumables
    [13445] = {buffID = 11348, name = "Elixir of Superior Defense", icon = "Interface\\Icons\\INV_Potion_66", duration = 3600},
    [3825]  = {buffID = 3593, name = "Elixir of Fortitude", icon = "Interface\\Icons\\INV_Potion_43", duration = 3600},
    [20079] = {buffID = 24382, name = "Spirit of Zanza", icon = "Interface\\Icons\\INV_Potion_30", duration = 7200},
    [13510] = {buffID = 17626, name = "Flask of the Titans", icon = "Interface\\Icons\\INV_Potion_62", duration = 7200},
    [9088]  = {buffID = 11371, name = "Gift of Arthas", icon = "Interface\\Icons\\INV_Potion_28", duration = 1800},
    [61175] = {buffID = 57107, name = "Medivh's Merlot Blue", icon = "Interface\\Icons\\INV_Potion_61", duration = 3600},
    [61174] = {buffID = 57106, name = "Medivh's Merlot", icon = "Interface\\Icons\\INV_Misc_Ribbon_01", duration = 3600},
    [10305] = {buffID = 12175, name = "Scroll of Protection IV", icon = "Interface\\Icons\\INV_Scroll_07", duration = 1800},
    [21151] = {buffID = 25804, name = "Rumsey Rum Black Label", icon = "Interface\\Icons\\INV_Drink_04", duration = 900},
    [12459] = {buffID = 16321, name = "Juju Escape", icon = "Interface\\Icons\\INV_Misc_MonsterScales_17", duration = 10},
    [12455] = {buffID = 16326, name = "Juju Ember", icon = "Interface\\Icons\\INV_Misc_MonsterScales_15", duration = 20},
    [12457] = {buffID = 16325, name = "Juju Chill", icon = "Interface\\Icons\\INV_Misc_MonsterScales_09", duration = 20},
    [51717] = {buffID = 25661, name = "Hardened Mushroom", icon = "Interface\\Icons\\INV_Mushroom_08", duration = 3600},
    [21023] = {buffID = 25661, name = "Dirge's Kickin' Chimaerok Chops", icon = "Interface\\Icons\\INV_Misc_Food_65", duration = 1200},
    [84040] = {buffID = 45623, name = "Le Fishe Au Chocolat", icon = "Interface\\Icons\\INV_Misc_MonsterScales_11", duration = 3600},
    -- Mana user consumables
    [61224] = {buffID = 45427, name = "Dreamshard Elixir", icon = "Interface\\Icons\\INV_Potion_12", duration = 3600},
    [13454] = {buffID = 17539, name = "Greater Arcane Elixir", icon = "Interface\\Icons\\INV_Potion_25", duration = 3600},
    [61423] = {buffID = 45489, name = "Dreamtonic", icon = "Interface\\Icons\\INV_Potion_10", duration = 3600},
    [13512] = {buffID = 17628, name = "Flask of Supreme Power", icon = "Interface\\Icons\\INV_Potion_41", duration = 7200},
    [20007] = {buffID = 24363, name = "Mageblood Potion", icon = "Interface\\Icons\\INV_Potion_45", duration = 3600},
    [8423]  = {buffID = 10692, name = "Cerebral Cortex Compound", icon = "Interface\\Icons\\INV_Potion_32", duration = 3600},
    [9264]  = {buffID = 11474, name = "Elixir of Shadow Power", icon = "Interface\\Icons\\INV_Potion_46", duration = 1800},
    [51718] = {buffID = 22731, name = "Juicy Striped Melon", icon = "Interface\\Icons\\INV_Misc_Food_22", duration = 3600},
    [13511] = {buffID = 17627, name = "Flask of Distilled Wisdom", icon = "Interface\\Icons\\INV_Potion_97", duration = 7200},
    [60977] = {buffID = 57043, name = "Danonzo's Tel'Abim Delight", icon = "Interface\\Icons\\INV_Drink_17", duration = 3600},
    [12458] = {buffID = 16327, name = "Juju Guile", icon = "Interface\\Icons\\INV_Misc_MonsterScales_13", duration = 3600},
    [13931] = {buffID = 18194, name = "Nightfin Soup", icon = "Interface\\Icons\\INV_Drink_17", duration = 600},
    [50237] = {buffID = 45988, name = "Elixir of Greater Nature Power", icon = "Interface\\Icons\\INV_Potion_22", duration = 3600},
    -- Protection Potions (all marked as On Use)
    [13461] = {buffID = 17549, name = "Greater Arcane Protection Potion", icon = "Interface\\Icons\\INV_Potion_83", duration = 3600, isOnUse = true},
    [13456] = {buffID = 17544, name = "Greater Frost Protection Potion", icon = "Interface\\Icons\\INV_Potion_20", duration = 3600, isOnUse = true},
    [6050]  = {buffID = 7239, name = "Frost Protection Potion", icon = "Interface\\Icons\\INV_Potion_13", duration = 1800, isOnUse = true},
    [13457] = {buffID = 17543, name = "Greater Fire Protection Potion", icon = "Interface\\Icons\\INV_Potion_24", duration = 3600, isOnUse = true},
    [6049]  = {buffID = 7233, name = "Fire Protection Potion", icon = "Interface\\Icons\\INV_Potion_16", duration = 1800, isOnUse = true},
    [13460] = {buffID = 17545, name = "Greater Holy Protection Potion", icon = "Interface\\Icons\\INV_Potion_09", duration = 3600, isOnUse = true},
    [6051]  = {buffID = 7245, name = "Holy Protection Potion", icon = "Interface\\Icons\\INV_Potion_09", duration = 1800, isOnUse = true},
    [13458] = {buffID = 17546, name = "Greater Nature Protection Potion", icon = "Interface\\Icons\\INV_Potion_22", duration = 3600, isOnUse = true},
    [6052]  = {buffID = 7254, name = "Nature Protection Potion", icon = "Interface\\Icons\\INV_Potion_06", duration = 1800, isOnUse = true},
    [13459] = {buffID = 17548, name = "Greater Shadow Protection Potion", icon = "Interface\\Icons\\INV_Potion_23", duration = 3600, isOnUse = true},
    [6048]  = {buffID = 7242, name = "Shadow Protection Potion", icon = "Interface\\Icons\\INV_Potion_44", duration = 1800, isOnUse = true},
    [9036]  = {buffID = 11364, name = "Magic Resistance Potion", icon = "Interface\\Icons\\INV_Potion_16", duration = 180, isOnUse = true},
    [13455] = {buffID = 17540, name = "Greater Stoneshield Potion", icon = "Interface\\Icons\\INV_Potion_69", duration = 120, isOnUse = true},
    [4623]  = {buffID = 4941, name = "Lesser Stoneshield Potion", icon = "Interface\\Icons\\INV_Potion_67", duration = 120, isOnUse = true},
    -- Uncategorized
    [20081] = {buffID = 24383, name = "Swiftness of Zanza", icon = "Interface\\Icons\\INV_Potion_31", duration = 7200},
    [61181] = {buffID = 45425, name = "Potion of Quickness", icon = "Interface\\Icons\\INV_Potion_25", duration = 3600, isOnUse = true},
    [5634] = {buffID = 6615, name = "Free Action Potion", icon = "Interface\\Icons\\INV_Potion_04", duration = 30, isOnUse = true},
    [3386] = {buffID = 26677, name = "Elixir of Poison Resistance", icon = "Interface\\Icons\\INV_Potion_12", duration = 30},
}

-- Saved variables to persist across sessions
RaidingConsumesDB = RaidingConsumesDB or {
    consumablesSelected = {}, -- Table of itemID -> buffID
    threshold = 120,          -- Default reapplication threshold in seconds
    PosX = 200,               -- GUI X position
    PosY = -200               -- GUI Y position
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


-- ### Global Variables for Restock Message Cooldown
local lastMessageTime = 0
local COOLDOWN_TIME = 10 -- 10-second cooldown for restock messages

-- ### Core Functionality

-- Create the addon frame and GUI
local RC = CreateFrame("Frame")
RC.ConfigFrame = CreateFrame("Frame", nil, UIParent)
RC.buttons = {}
-- In your initialization code somewhere:
-- Somewhere in your initialization code:
RC.ConfigFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
RC.ConfigFrame:SetScript("OnEvent", function()
    if event == "PLAYER_AURAS_CHANGED" then
        RC:UpdateGUI()
    end
end)




-- Setup the main frame (modeled after EZP.ConfigFrame)
local backdrop = {
    bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 5, top = 3, bottom = 5 }
}
RC.ConfigFrame:SetBackdrop(backdrop)
RC.ConfigFrame:SetBackdropColor(0, 0, 0, 0.8)
RC.ConfigFrame:SetWidth(100) -- Initial width for empty state
RC.ConfigFrame:SetHeight(48)
RC.ConfigFrame:SetMovable(1)
RC.ConfigFrame:EnableMouse(1)
RC.ConfigFrame:RegisterForDrag("LeftButton")
RC.ConfigFrame:SetScript("OnDragStart", function() RC.ConfigFrame:StartMoving() end)
RC.ConfigFrame:SetScript("OnDragStop", function()
    RC.ConfigFrame:StopMovingOrSizing()
    _, _, _, RaidingConsumesDB.PosX, RaidingConsumesDB.PosY = RC.ConfigFrame:GetPoint()
end)

-- Create a pool of 10 buttons
for i = 1, 15 do
    local button = CreateFrame("Button", nil, RC.ConfigFrame)
    button:SetWidth(32)
    button:SetHeight(32)
    button:Hide()

    -- Create (or reuse) a FontString for the timer
    if not button.timerText then
        button.timerText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.timerText:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.timerText:SetText("")  -- Start blank
    end

    -- Create overlay texture for active buff effect
    button.overlay = button:CreateTexture(nil, "OVERLAY")
    button.overlay:SetAllPoints()
    button.overlay:SetTexture(0, 1, 0, 0.3) -- Green with 30% opacity
    button.overlay:Hide()

    table.insert(RC.buttons, button)
end

-- ##################################################
-- Function to update timer text on each button
-- ##################################################
function RC:UpdateTimers()
    local currentTime = GetTime()
    local threshold = RaidingConsumesDB.threshold or 120
    local sharedCooldown = math.max(0, ON_USE_COOLDOWN - (currentTime - lastOnUseTime))

    for i, button in ipairs(self.buttons) do
        if button:IsShown() and button.itemID then
            local itemID = button.itemID
            local data = consumablesDB[itemID]
            local buffID = RaidingConsumesDB.consumablesSelected[itemID]
            local foundTimeLeft = 0

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
                if foundTimeLeft > 0 then
                    -- Buff active: full alpha, green overlay, buff timer
                    button:SetAlpha(1.0)
                    button.overlay:Show()
                    local totalSeconds = math.floor(foundTimeLeft)
                    local mins = math.floor(totalSeconds / 60)
                    local secs = totalSeconds - (mins * 60)
                    button.timerText:SetText(string.format("%d:%02d", mins, secs))
                elseif sharedCooldown > 0 then
                    -- On cooldown: 30% alpha, cooldown timer
                    button:SetAlpha(0.3)
                    button.overlay:Hide()
                    local totalSeconds = math.floor(sharedCooldown)
                    local mins = math.floor(totalSeconds / 60)
                    local secs = totalSeconds - (mins * 60)
                    button.timerText:SetText(string.format("%d:%02d", mins, secs))
                else
                    -- Ready to use: full alpha, no timer
                    button:SetAlpha(1.0)
                    button.overlay:Hide()
                    button.timerText:SetText("")
                end
                button:GetNormalTexture():SetVertexColor(1, 1, 1) -- No tint for On Use items
            else
                -- Regular consumable
                if foundTimeLeft > 0 then
                    -- Buff active
                    button:SetAlpha(1.0)
                    local totalSeconds = math.floor(foundTimeLeft)
                    local mins = math.floor(totalSeconds / 60)
                    local secs = totalSeconds - (mins * 60)
                    button.timerText:SetText(string.format("%d:%02d", mins, secs))
                    if totalSeconds <= threshold then
                        button:GetNormalTexture():SetVertexColor(1, 0, 0) -- Red tint
                    else
                        button:GetNormalTexture():SetVertexColor(1, 1, 1)
                    end
                else
                    -- No buff active
                    button.timerText:SetText("")
                    button:GetNormalTexture():SetVertexColor(1, 1, 1)
                    button:SetAlpha(0.3)
                end
            end
        else
            -- Hidden button or no itemID
            if button.timerText then
                button.timerText:SetText("")
            end
            if button.overlay then
                button.overlay:Hide()
            end
        end
    end
end

-- Function to update the GUI
function RC:UpdateGUI()
    local selected = {}
    for itemID, _ in pairs(RaidingConsumesDB.consumablesSelected) do
        table.insert(selected, itemID)
    end
    table.sort(selected, function(a, b)
        return consumablesDB[a].name < consumablesDB[b].name
    end)
    
    local numButtons = 0
    for _ in pairs(selected) do numButtons = numButtons + 1 end -- Count manually for Vanilla Lua
    
    local buttonSize = 32
    local spacing = 5
    local currentX = 5 -- Left padding
    
    for i = 1, 15 do
        local button = RC.buttons[i]
        if i <= numButtons then
            local itemID = selected[i]
            local icon = consumablesDB[itemID].icon
            button:SetNormalTexture(icon)
            button.itemID = itemID
            
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
            
            -- Position the button
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", RC.ConfigFrame, "TOPLEFT", currentX, -8)
            button:Show()
            
            -- >>> SET ALPHA BASED ON BUFF ACTIVE OR NOT <<<
            local buffID = RaidingConsumesDB.consumablesSelected[itemID]
            if HasBuff(buffID, RaidingConsumesDB.threshold) then
                button:SetAlpha(1.0)  -- Buff is considered active above threshold
            else
                button:SetAlpha(0.3)  -- Buff not active (or under threshold)
            end
            
            currentX = currentX + buttonSize + spacing
        else
            button:Hide()
        end
    end
    
    -- Adjust frame width
    if numButtons > 0 then
        RC.ConfigFrame:SetWidth(currentX) -- Right edge after last button
    else
        RC.ConfigFrame:SetWidth(100) -- Default empty width
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
        -- For On Use items, always attempt to use if available
        if HasItem(itemID) then
            FindAndUseItem(itemID)
            lastOnUseTime = GetTime() -- Start shared cooldown
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
        if RC.ConfigFrame:IsShown() then
            RC.ConfigFrame:Hide()
        else
            RC:UpdateGUI()
            RC.ConfigFrame:Show()
        end
        return
    end
    
    local lowerMsg = string.lower(msg)
    local args = strsplit(" ", lowerMsg)
    local cmd = args[1]                 -- Line 253
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
        end

    elseif cmd == "threshold" then
        local seconds = tonumber(args[1])
        if seconds and seconds > 0 then
            RaidingConsumesDB.threshold = seconds
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Reapplication threshold set to " .. seconds .. " seconds.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Usage: /rc threshold [seconds]")
        end

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
    
    -- Now that RaidingConsumesDB is guaranteed loaded, position the frame
    RC.ConfigFrame:ClearAllPoints()
    RC.ConfigFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", RaidingConsumesDB.PosX, RaidingConsumesDB.PosY)

    -- Update the GUI
    RC:UpdateGUI()

    -- Show/Hide if we have selected buffs
    local count = 0
    for _ in pairs(RaidingConsumesDB.consumablesSelected) do
        count = count + 1
    end
    if count > 0 then
        RC.ConfigFrame:Show()
    else
        RC.ConfigFrame:Hide()
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
        RC:UpdateTimers()
        lastUpdate = currentTime
    end
end)
