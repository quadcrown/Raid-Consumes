-- Complete database of consumables: itemID -> {buffID, name}
local consumablesDB = {
    [12451] = {buffID = 16323, name = "Juju Power"},
    [9206]  = {buffID = 11405, name = "Elixir of Giants"},
    [13452] = {buffID = 17538, name = "Elixir of the Mongoose"},
    [12820] = {buffID = 17038, name = "Winterfall Firewater"},
    [8410]  = {buffID = 10667, name = "R.O.I.D.S"},
    [13445] = {buffID = 11348, name = "Elixir of Superior Defense"},
    [3825]  = {buffID = 3593,  name = "Elixir of Fortitude"},
    [20079] = {buffID = 24382, name = "Spirit of Zanza"},
    [21151] = {buffID = 25804, name = "Rumsey Rum Black Label"},
    [8412]  = {buffID = 10669, name = "Ground Scorpok Assay"},
    [9088]  = {buffID = 11371, name = "Gift of Arthas"},
    [9187]  = {buffID = 11334, name = "Elixir of Greater Agility"},
    [61224] = {buffID = 45427, name = "Dreamshard Elixir"},
    [13454] = {buffID = 17539, name = "Greater Arcane Elixir"},
    [61423] = {buffID = 45489, name = "Dreamtonic"},
    [13512] = {buffID = 17628, name = "Flask of Supreme Power"},
    [60977] = {buffID = 57043, name = "Danonzo's Tel'Abim Delight"},
    [20007] = {buffID = 24363, name = "Mageblood Potion"},
    [61175] = {buffID = 57107, name = "Medivh's Merlot Blue"},
    [61174] = {buffID = 57106, name = "Medivh's Merlot"}
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
        print("Usage: /rc [list of consumables] | /rc threshold [seconds] | /rc list | /rc reset")
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
            print("No consumables selected.")
        else
            print("Selected consumables: " .. table.concat(selected, ", "))
        end

    elseif cmd == "threshold" then
        -- Set the reapplication threshold
        local seconds = tonumber(args[1])
        if seconds and seconds > 0 then
            RaidingConsumesDB.threshold = seconds
            print("Reapplication threshold set to " .. seconds .. " seconds.")
        else
            print("Usage: /rc threshold [seconds] -- This is the time left on the buff at which you can use /usecons to reapply that particular buff")
        end

    elseif cmd == "reset" then
        -- Clear our table of consumables
        RaidingConsumesDB.consumablesSelected = {}
        print("Consumables selection has been reset.")

    else
        -- We assume the user wants to add new items, e.g. /rc Juju Power, Elixir of the Mongoose
        local input = strsplit(",", msg) -- split by commas from the *original* msg (not lowerMsg, if you want case for printing)
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
                print("Added '" .. consumablesDB[itemID].name .. "' to your selected consumables.")
            else
                print("Consumable '" .. name .. "' not found in database.")
            end
        end

        if anyFound then
            print("Selected consumables updated. Use /rc list to see them.")
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
local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:SetScript("OnEvent", function(self, event)
    if event == "VARIABLES_LOADED" then
        RaidingConsumes_Initialize()
        print("[Raiding Consumes] loaded. Use /rc to configure.")
    end
end)
