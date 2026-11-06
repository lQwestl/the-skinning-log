local _, S = ...
S.version = "0.4.3"
S.title = "The Skinning Log"
S.icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01"
S.Model = {}
local M = S.Model
local floor = math.floor

function S.Count(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end

function S.Copy(t)
    if type(t) ~= "table" then return t end
    local result = {}
    for k, v in pairs(t) do result[k] = S.Copy(v) end
    return result
end

function S.Money(copper)
    copper = floor(tonumber(copper) or 0)
    if copper >= 10000 then return string.format("%.1fg", copper / 10000) end
    if copper >= 100 then return string.format("%.1fs", copper / 100) end
    return copper .. "c"
end

function S.Duration(seconds)
    seconds = math.max(0, floor(seconds or 0))
    return string.format("%02d:%02d:%02d", floor(seconds / 3600), floor(seconds / 60) % 60, seconds % 60)
end

function S.CSV(value)
    local text = tostring(value or "")
    if text:match("^[=+@%-%s]") then text = "'" .. text end
    return '"' .. text:gsub('"', '""') .. '"'
end

function M:CSV()
    local lines = { "NPC ID,Creature,Skins,Materials,Units per skin,Zones" }
    for _, c in ipairs(self:Creatures("", "all", "name")) do
        local zones = {}
        for _, z in pairs(c.zones) do zones[#zones + 1] = z.name end
        table.sort(zones)
        lines[#lines + 1] = table.concat({ S.CSV(c.npcID), S.CSV(c.name), c.skins, c.units,
            string.format("%.3f", c.units / c.skins), S.CSV(table.concat(zones, "; ")) }, ",")
    end
    return table.concat(lines, "\r\n")
end

function S.Rank(skins)
    if skins >= 100 then return "Master", 100, 100 end
    if skins >= 50 then return "Expert", skins, 100 end
    if skins >= 10 then return "Tracker", skins, 50 end
    return "Discovered", skins, 10
end

function M:Empty()
    return { skins = 0, units = 0, creatures = {}, items = {}, zones = {}, history = {} }
end

function M:Init()
    SkinningLogSolDB = SkinningLogSolDB or {}
    local db = SkinningLogSolDB
    db.schema = 2
    db.all = db.all or self:Empty()
    db.characters = db.characters or {}
    db.settings = db.settings or {}
    local defaults = { enabled = true, announce = true, tooltips = true, minimap = true, minimapAngle = 215, scope = "all",
        hud = true, hudExpanded = false, hudScale = 1, worldPins = true, miniPins = false,
        sound = false, motion = true, journalScale = 0.9, lootText = true }
    for k, v in pairs(defaults) do if db.settings[k] == nil then db.settings[k] = v end end
    db.notes = db.notes or {}
    db.favorites = db.favorites or {}
    db.recent = db.recent or {}
    self.db = db
    self.character = (UnitName("player") or "Unknown") .. " - " .. (GetRealmName() or "Unknown")
    db.characters[self.character] = db.characters[self.character] or self:Empty()
    if S.Research then S.Research:Init() end
    self:NewSession()
end

function M:Data(recordedOnly)
    if S.demo and not recordedOnly then return S.demo.data end
    if self.db.settings.scope == "character" then return self.db.characters[self.character] end
    return self.db.all
end

function M:Session()
    return S.demo and S.demo.session or self.session
end

function M:NewSession()
    if self.session and self.session.skins > 0 then self:ArchiveSession() end
    self.session = self:Empty()
    self.session.start = time()
    self.session.character = self.character
    self.session.xp = 0
    if S.HUD then S.HUD:Refresh() end
end

function M:ArchiveSession()
    local session = self.session
    if not session or session.skins == 0 or session.archived then return end
    self.db.sessions = self.db.sessions or {}
    table.insert(self.db.sessions, 1, {
        start = session.start, duration = time() - session.start,
        skins = session.skins, units = session.units,
        species = S.Count(session.creatures), character = session.character,
        xp = session.xp or 0,
    })
    while #self.db.sessions > 20 do table.remove(self.db.sessions) end
    session.archived = true
end

function M:Price(itemID)
    local api = Auctionator and Auctionator.API and Auctionator.API.v1
    if api and api.GetAuctionPriceByItemID then
        local ok, price = pcall(api.GetAuctionPriceByItemID, "the-skinning-log-sol", itemID)
        if ok and type(price) == "number" and price > 0 then return price, "AH estimate" end
    end
    local getInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
    if getInfo then
        local _, _, _, _, _, _, _, _, _, _, vendor = getInfo(itemID)
        if vendor and vendor > 0 then return vendor, "Vendor" end
    end
    return 0, "No price"
end

function M:Value(data)
    local total = 0
    for id, item in pairs((data or self:Data()).items) do total = total + self:Price(id) * item.count end
    return total
end

function M:CreatureKey(record)
    return record.npcID and tostring(record.npcID) or ("unknown:" .. (record.name or "Unknown"))
end

-- Bounded spatial buckets retain lifetime totals without saving one point per corpse.
-- Coordinates describe the PLAYER at the cast, not the exact corpse position.
function M:Aggregate(data, record)
    local addedSkin = record.supplement and 0 or 1
    local key = self:CreatureKey(record)
    local creature = data.creatures[key]
    if not creature then
        creature = { key = key, npcID = record.npcID, name = record.name or "Unidentified creature", skins = 0,
            units = 0, items = {}, zones = {}, first = record.at, last = record.at,
            levelMin = record.level, levelMax = record.level, family = record.family }
        data.creatures[key] = creature
    end
    if record.name and record.name ~= "Unidentified creature" then creature.name = record.name end
    creature.last = record.at
    if record.level and record.level > 0 then
        creature.levelMin = math.min(creature.levelMin or record.level, record.level)
        creature.levelMax = math.max(creature.levelMax or record.level, record.level)
    end
    creature.skins = creature.skins + addedSkin
    data.skins = data.skins + addedSkin
    local mapKey = record.mapID or 0
    local zone = data.zones[mapKey]
    if not zone then
        zone = { mapID = record.mapID, name = record.zone or "Unknown zone", skins = 0, units = 0, creatures = {}, spots = {} }
        data.zones[mapKey] = zone
    end
    zone.skins = zone.skins + addedSkin
    zone.last = record.at
    zone.creatures[key] = (zone.creatures[key] or 0) + addedSkin
    local cz = creature.zones[mapKey]
    if not cz then cz = { skins = 0, units = 0, name = zone.name }; creature.zones[mapKey] = cz end
    cz.skins = cz.skins + addedSkin
    local spot
    if record.x and record.y and record.mapID then
        local gx, gy = math.min(49, floor(record.x * 50)), math.min(49, floor(record.y * 50))
        local cell = gx .. ":" .. gy
        spot = zone.spots[cell]
        if not spot then
            spot = { x = record.x, y = record.y, skins = 0, units = 0, creatures = {}, items = {} }
            zone.spots[cell] = spot
        end
        if addedSkin > 0 then
            spot.x = (spot.x * spot.skins + record.x) / (spot.skins + 1)
            spot.y = (spot.y * spot.skins + record.y) / (spot.skins + 1)
        end
        spot.skins = spot.skins + addedSkin
        spot.last = record.at
        local sc = spot.creatures[key] or { skins = 0, units = 0 }
        sc.skins = sc.skins + addedSkin
        spot.creatures[key] = sc
    end
    local recordUnits = 0
    for id, loot in pairs(record.items) do
        local qty = loot.count
        local item = data.items[id]
        if not item then
            item = { id = id, name = loot.name or ("Item " .. id), link = loot.link, icon = loot.icon, quality = loot.quality,
                count = 0, drops = 0, creatures = {} }
            data.items[id] = item
        end
        item.count = item.count + qty
        item.quality = loot.quality or item.quality
        local addedDrop = loot.alreadyDropped and 0 or 1
        item.drops = item.drops + addedDrop
        item.creatures[key] = (item.creatures[key] or 0) + qty
        local ci = creature.items[id] or { count = 0, drops = 0 }
        ci.count = ci.count + qty
        ci.drops = ci.drops + addedDrop
        creature.items[id] = ci
        recordUnits = recordUnits + qty
        if spot then spot.items[id] = (spot.items[id] or 0) + qty end
        if spot then
            local sc = spot.creatures[key]
            sc.items = sc.items or {}
            sc.items[id] = (sc.items[id] or 0) + qty
        end
    end
    creature.units = creature.units + recordUnits
    data.units = data.units + recordUnits
    zone.units = zone.units + recordUnits
    cz.units = cz.units + recordUnits
    if spot then
        spot.units = spot.units + recordUnits
        spot.creatures[key].units = spot.creatures[key].units + recordUnits
    end
    data.first = data.first or record.at
    data.last = record.at
    local entry = { at = record.at, guid = record.guid, key = key, name = creature.name, zone = zone.name,
        mapID = record.mapID, x = record.x, y = record.y, units = recordUnits, items = S.Copy(record.items) }
    local amended
    if record.supplement and record.guid then
        for _, h in ipairs(data.history) do
            if h.guid == record.guid then
                h.units = h.units + recordUnits
                for id, loot in pairs(record.items) do
                    if h.items[id] then h.items[id].count = h.items[id].count + loot.count else h.items[id] = S.Copy(loot) end
                end
                amended = true; break
            end
        end
    end
    if not amended then table.insert(data.history, 1, entry) end
    while #data.history > 100 do table.remove(data.history) end
    return creature
end

function M:Commit(record)
    if not self.db.settings.enabled or not next(record.items) then return false end
    local previous = record.guid and self.db.recent[record.guid]
    if previous then
        if not record.supplement or type(previous) ~= "table" or previous.batches[record.batch] then return false end
        for id, loot in pairs(record.items) do loot.alreadyDropped = previous.items[id] end
    elseif record.supplement then return false end
    record.at = record.at or time()
    local key = self:CreatureKey(record)
    local discovery = not self.db.all.creatures[key]
    local characterData = self.db.characters[self.character]
    local oldSkins = characterData.creatures[key] and characterData.creatures[key].skins or 0
    local newZone = record.mapID and not characterData.zones[record.mapID]
    self:Aggregate(self.db.all, record)
    self:Aggregate(self.db.characters[self.character], record)
    if self.session.skins == 0 then self.session.start = record.at end
    self:Aggregate(self.session, record)
    local gained, reasons = 0, {}
    if S.Research and not record.supplement then
        gained, reasons = S.Research:Record(record, oldSkins, newZone)
    end
    self.session.xp = (self.session.xp or 0) + gained
    if record.guid then
        local recent = previous or { at = record.at, items = {}, batches = {} }
        if record.batch then recent.batches[record.batch] = true end
        for id in pairs(record.items) do recent.items[id] = true end
        self.db.recent[record.guid] = recent
    end
    for guid, value in pairs(self.db.recent) do
        local at = type(value) == "table" and value.at or value
        if record.at - at > 86400 then self.db.recent[guid] = nil end
    end
    if S.Count(self.db.recent) > 512 then
        local oldest, oldestAt
        for guid, value in pairs(self.db.recent) do
            local at = type(value) == "table" and value.at or value
            if not oldestAt or at < oldestAt then oldest, oldestAt = guid, at end
        end
        self.db.recent[oldest] = nil
    end
    if discovery and self.db.settings.announce then
        S:Print(S.Fmt("Discovered: %s", record.name))
        if S.Notice then S:Notice({ kind = "discovery", key = key, title = "New discovery", name = record.name,
            family = record.family, npcID = record.npcID, subtitle = S.Fmt("%s · %d species discovered", record.zone or "", S.Count(self.db.all.creatures)), xp = 40 }) end
    end
    if S.LootText then S.LootText:Display(record) end
    local goal = self.db.goal
    if goal and goal.character == self.character and not goal.complete then
        local count = self.db.characters[self.character].items[goal.itemID]
        if count and count.count - goal.baseline >= goal.target then
            goal.complete = true
            local bonus = S.Research and S.Research:GoalComplete(goal) or 0
            self.session.xp = (self.session.xp or 0) + bonus
            S:Print(S.Fmt("Goal complete: %s", goal.name))
            if S.Notice then S:Notice({ kind = "goal", title = "Goal complete", name = goal.name,
                subtitle = S.Fmt("%d materials collected", goal.target), icon = self.db.all.items[goal.itemID].icon, xp = bonus }) end
        end
    end
    if S.UI then S.UI:Refresh() end
    if S.HUD then S.HUD:Refresh() end
    if S.Maps then S.Maps:Dirty() end
    return true
end

function M:Creatures(search, filter, sort)
    local data = self:Data()
    local result = {}
    search = (search or ""):lower()
    for key, c in pairs(data.creatures) do
        local match = search == "" or c.name:lower():find(search, 1, true) or tostring(c.npcID or ""):find(search, 1, true)
        if not match then
            for id in pairs(c.items) do
                local item = data.items[id]
                if item and item.name:lower():find(search, 1, true) then match = true; break end
            end
            for _, z in pairs(c.zones) do if z.name:lower():find(search, 1, true) then match = true; break end end
        end
        if match and (filter ~= "favorites" or self.db.favorites[key]) and (filter ~= "mastered" or c.skins >= 100) then
            result[#result + 1] = c
        end
    end
    table.sort(result, function(a, b)
        if sort == "name" then return a.name < b.name end
        if sort == "yield" and a.units ~= b.units then return a.units > b.units end
        if sort == "average" and a.units / a.skins ~= b.units / b.skins then return a.units / a.skins > b.units / b.skins end
        if sort == "recent" and a.last ~= b.last then return a.last > b.last end
        if a.skins ~= b.skins then return a.skins > b.skins end
        return a.name < b.name
    end)
    return result
end

function M:Goal(item, target)
    local current = self.db.characters[self.character].items[item.id]
    self.db.goal = { itemID = item.id, name = item.name, target = target, baseline = current and current.count or 0,
        character = self.character }
    if S.HUD then S.HUD:Refresh() end
end

function M:GoalProgress(recordedOnly)
    local demo = not recordedOnly and S.demo
    local goal = demo and demo.goal or self.db.goal
    if not goal then return nil end
    if goal.character and goal.character ~= self.character then return goal, 0, true end
    local data = demo and demo.data or self.db.characters[self.character]
    local item = data.items[goal.itemID]
    return goal, math.min(goal.target, math.max(0, (item and item.count or 0) - goal.baseline))
end
