-- Complete database of consumables: itemID -> {buffID, name}
local consumablesDB = {
    -- [] = {buffID = , name = ""}
    -- Melee/ranged power/crit consumables
    [12451] = {buffID = 16323, name = "Juju Power"},
    [9206]  = {buffID = 11405, name = "Elixir of Giants"},
    [12820] = {buffID = 17038, name = "Winterfall Firewater"},
    [12460] = {buffID = 16329, name = "Juju Might"},
    [9224] = {buffID = 11406, name = "Elixir of Demonslaying"},
    [13452] = {buffID = 17538, name = "Elixir of the Mongoose"},
    [9187]  = {buffID = 11334, name = "Elixir of Greater Agility"},
    [8410]  = {buffID = 10667, name = "R.O.I.D.S"},
    [8412]  = {buffID = 10669, name = "Ground Scorpok Assay"},
    [5206] = {buffID = 5665, name = "Bogling Root"},
    [12450] = {buffID = 16322, name = "Juju Flurry"},
    [60976] = {buffID = 57042, name = "Danonzo's Tel'Abim Surprise"},
    [51711] = {buffID = 18192, name = "Sweet Mountain Berry" },
    [13928] = {buffID = 18192, name = "Grilled Squid"},
    [60978] = {buffID = 57046, name = "Danonzo's Tel'Abim Medley"},
    [20452] = {buffID = 24799, name = "Smoked Desert Dumplings"},
    [51720] = {buffID = 24799, name = "Power Mushroom"},
    [51267] = {buffID = 24799, name = "Spicy Beef Burrito"},
    [13442] = {buffID = 17528, name = "Mighty Rage Potion"},
    [5633] = {buffID = 6613, name = "Great Rage Potion"},
    -- Tank/Defensive/Stamina consumables
    [13445] = {buffID = 11348, name = "Elixir of Superior Defense"},
    [3825]  = {buffID = 3593,  name = "Elixir of Fortitude"},
    [20079] = {buffID = 24382, name = "Spirit of Zanza"},
    [13510] = {buffID = 17626, name = "Flask of the Titans"},
    [9088]  = {buffID = 11371, name = "Gift of Arthas"},
    [61175] = {buffID = 57107, name = "Medivh's Merlot Blue"},
    [61174] = {buffID = 57106, name = "Medivh's Merlot"},
    [10305] = {buffID = 12175, name = "Scroll of Protection IV"},
    [21151] = {buffID = 25804, name = "Rumsey Rum Black Label"},
    [12459] = {buffID = 16321, name = "Juju Escape"},
    [12455] = {buffID = 16326, name = "Juju Ember"},
    [12457] = {buffID = 16325, name = "Juju Chill"},
    [51717] = {buffID = 25661, name = "Hardened Mushroom"},
    [21023] = {buffID = 25661, name = "Dirge's Kickin' Chimaerok Chops"},
    [84040] = {buffID = 45623, name = "Le Fishe Au Chocolat"},
    -- Mana user consumables
    [61224] = {buffID = 45427, name = "Dreamshard Elixir"},
    [13454] = {buffID = 17539, name = "Greater Arcane Elixir"},
    [61423] = {buffID = 45489, name = "Dreamtonic"},
    [13512] = {buffID = 17628, name = "Flask of Supreme Power"},
    [20007] = {buffID = 24363, name = "Mageblood Potion"},
    [8423] = {buffID = 10692, name = "Cerebral Cortex Compound"},
    [9264] = {buffID = 11474, name = "Elixir of Shadow Power"},
    [51718] = {buffID = 22731, name = "Juicy Striped Melon"},
    [13512] = {buffID = 17628, name = "Flask of Supreme Power"},
    [13511] = {buffID = 17627, name = "Flask of Distilled Wisdom"},
    [60977] = {buffID = 57043, name = "Danonzo's Tel'Abim Delight"},
    [12458] = {buffID = 16327, name = "Juju Guile"},
    [13931] = {buffID = 18194, name = "Nightfin Soup"},
    -- Protection Potions
    [13461] = {buffID = 17549, name = "Greater Arcane Protection Potion"},
    [13456] = {buffID = 17544, name = "Greater Frost Protection Potion"},
    [6050] = {buffID = 7239, name = "Frost Protection Potion"},
    [13457] = {buffID = 17543, name = "Greater Fire Protection Potion"},
    [6049] = {buffID = 7233, name = "Fire Protection Potion"},
    [13460] = {buffID = 17545, name = "Greater Holy Protection Potion"},
    [6051] = {buffID = 7245, name = "Holy Protection Potion"},
    [13458] = {buffID = 17546, name = "Greater Nature Protection Potion"},
    [6052] = {buffID = 7254, name = "Nature Protection Potion"},
    [13459] = {buffID = 17548, name = "Greater Shadow Protection Potion"},
    [6048] = {buffID = 7242, name = "Shadow Protection Potion"},
    [9036] = {buffID = 11364, name = "Magic Resistance Potion"},
    [13455] = {buffID = 17540, name = "Greater Stoneshield Potion"},
    [4623] = {buffID = 4941, name = "Lesser Stoneshield Potion"},
    -- Uncategorized
    [20081] = {buffID = 24383, name = "Swiftness of Zanza"},
    [61181] = {buffID = 45425, name = "Potion of Quickness"},
}

-- Saved variables to persist across sessions
RaidingConsumesDB = RaidingConsumesDB or {
    consumablesSelected = {}, -- Table of itemID -> buffID
    threshold = 120           -- Default reapplication threshold in seconds
}


-- ### Helper Functions

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

-- ### Global Variables for Restock Message Cooldown
local lastMessageTime = 0
local COOLDOWN_TIME = 10 -- 10-second cooldown for restock messages

-- ### Core Functionality

-- **Apply selected consumables based on threshold and inventory**
local function UseConsumables()
    local missingItems = {}
    for itemID, buffID in pairs(RaidingConsumesDB.consumablesSelected) do
        if not HasBuff(buffID, RaidingConsumesDB.threshold) then
            if HasItem(itemID) then
                FindAndUseItem(itemID)
            else
                local data = consumablesDB[itemID]
                if data then
                    table.insert(missingItems, data.name)
                end
            end
        end
    end

    -- Print a single restock message if items are missing, with cooldown
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

-- **Slash command handler for configuration**
local function RaidingConsumes_SlashCommand(msg)
    if not msg or msg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Usage: /rc <list of consumables> to set | /rc remove <list of consumables> to remove | /rc threshold <seconds> | /rc list | /rc reset")
        return
    end
    
    -- Convert the entire message to lowercase for matching commands
    local lowerMsg = string.lower(msg)
    
    -- Split out the first token
    local args = strsplit(" ", lowerMsg)
    local cmd = args[1]
    table.remove(args, 1)

    if cmd == "list" then
        -- Print currently selected consumables
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
        -- Set the reapplication threshold
        local seconds = tonumber(args[1])
        if seconds and seconds > 0 then
            RaidingConsumesDB.threshold = seconds
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Reapplication threshold set to " .. seconds .. " seconds.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Usage: /rc threshold [seconds] -- This is the time left on the buff at which you can use /usecons to reapply that particular buff")
        end

    elseif cmd == "reset" then
        -- Clear our table of consumables
        RaidingConsumesDB.consumablesSelected = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Consumables selection has been reset.")

    elseif cmd == "remove" then
        local removeList = table.concat(args, " ")
        if removeList == "" then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Please specify consumables to remove, e.g., /rc remove Juju Power, Elixir of the Mongoose")
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

    else
        -- We assume the user wants to add new items, e.g. /rc Juju Power, Elixir of the Mongoose
        local input = strsplit(",", msg) -- split by commas from the *original* msg
        local anyFound = false

        -- For each comma-delimited name, trim/lower and find in database
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
                -- Insert or overwrite into the existing table
                RaidingConsumesDB.consumablesSelected[itemID] = consumablesDB[itemID].buffID
                anyFound = true
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Added '" .. consumablesDB[itemID].name .. "' to your selected consumables.")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Consumable '" .. name .. "' not found in database.")
            end
        end

        if anyFound then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r Selected consumables updated. Use /rc list to see them.")
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
    RaidingConsumesDB.threshold = RaidingConsumesDB.threshold or 120
    RaidingConsumesDB.consumablesSelected = RaidingConsumesDB.consumablesSelected or {}
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
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RaidConsumes]|r loaded. Please type /rc for help.")
    end
end)
