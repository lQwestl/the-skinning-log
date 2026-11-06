local _, S = ...
S.Tracker = { cache = {}, sequence = 0 }
local T = S.Tracker

function T:NPCID(guid)
    if type(guid) ~= "string" then return nil end
    local kind, _, _, _, _, id = strsplit("-", guid)
    if kind == "Creature" or kind == "Vehicle" then return tonumber(id) end
end

function T:Location()
    local mapID = C_Map and C_Map.GetBestMapForUnit("player")
    local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    local x, y
    if pos then x, y = pos:GetXY() end
    if not x or not y or (x == 0 and y == 0) or x < 0 or y < 0 or x > 1 or y > 1 then x, y = nil, nil end
    return { mapID = mapID, x = x, y = y, zone = GetZoneText() or "Unknown zone", subzone = GetSubZoneText() }
end

function T:Observe(unit)
    local guid = UnitGUID(unit)
    local id = self:NPCID(guid)
    if not id then return end
    local c = { guid = guid, npcID = id, name = UnitName(unit), level = UnitLevel(unit),
        family = UnitCreatureFamily(unit) or UnitCreatureType(unit), seen = GetTime() }
    self.cache[guid] = c
    if S.Count(self.cache) > 200 then
        local oldest, seen
        for g, v in pairs(self.cache) do if not seen or v.seen < seen then oldest, seen = g, v.seen end end
        self.cache[oldest] = nil
    end
    return c
end

function T:IsSkinning(spellID)
    if tonumber(spellID) == 8613 then return true end
    local name, skinName
    if C_Spell and C_Spell.GetSpellInfo then
        local a, b = C_Spell.GetSpellInfo(spellID), C_Spell.GetSpellInfo(8613)
        name, skinName = a and a.name, b and b.name
    elseif GetSpellInfo then name, skinName = GetSpellInfo(spellID), GetSpellInfo(8613) end
    return name and skinName and name == skinName
end

function T:Begin(targetName, castGUID)
    self:Observe("target")
    self:Observe("mouseover")
    local chosen
    -- SENT supplies the cast target's name even when skinning via mouseover.
    for _, unit in ipairs({ "mouseover", "target" }) do
        local c = self.cache[UnitGUID(unit) or ""]
        if c and (not targetName or targetName == "" or c.name == targetName) then chosen = c; break end
    end
    if not chosen and targetName and targetName ~= "" then
        for _, c in pairs(self.cache) do
            if c.name == targetName and GetTime() - c.seen < 3 and (not chosen or c.seen > chosen.seen) then chosen = c end
        end
    end
    self.sequence = self.sequence + 1
    self.pending = self:Location()
    for k, v in pairs(chosen or {}) do self.pending[k] = v end
    self.pending.name = targetName and targetName ~= "" and targetName or (chosen and chosen.name or "Unidentified creature")
    self.pending.castGUID = castGUID
    self.pending.started = GetTime()
    self.pending.token = self.sequence
end

function T:Success(castGUID)
    if not self.pending or (castGUID and self.pending.castGUID and castGUID ~= self.pending.castGUID) then self:Begin(nil, castGUID) end
    self.pending.success = GetTime()
    if self.window and self.window.token == self.pending.token then self.window.success = true end
end

function T:ReadLoot()
    local p = self.pending
    if not p or GetTime() - (p.success or p.started) > (p.completed and 60 or 5) then return end
    if not self.window then
        self.windowSequence = (self.windowSequence or 0) + 1
        self.window = { record = S.Copy(p), slots = {}, token = p.token, success = p.success ~= nil }
        self.window.record.batch = self.windowSequence
    end
    local window = self.window
    if window.token ~= p.token then return end
    for slot = 1, GetNumLootItems() do
        if not window.slots[slot] then
            local link = GetLootSlotLink(slot)
            local itemID = link and tonumber(link:match("item:(%d+)"))
            if itemID then
                local icon, name, qty, _, quality = GetLootSlotInfo(slot)
                local sourceGUID
                local sourceQuantity
                local valid = true
                if GetLootSourceInfo then
                    local sources = { GetLootSourceInfo(slot) }
                    -- The API returns (GUID, quantity) pairs, without a count prefix.
                    for i = 1, #sources, 2 do
                        if self:NPCID(sources[i]) then
                            if not p.guid or sources[i] == p.guid then sourceGUID, sourceQuantity = sources[i], sources[i + 1]; break end
                        end
                    end
                    if #sources > 0 and not sourceGUID then valid = false end
                end
                if p.completed and not sourceGUID then valid = false end
                if sourceQuantity then qty = math.min(qty or 0, sourceQuantity) end
                if valid and (qty or 0) > 0 then
                    if sourceGUID then
                        window.record.guid = sourceGUID
                        window.record.npcID = self:NPCID(sourceGUID)
                        local observed = self.cache[sourceGUID]
                        if observed then
                            window.record.name, window.record.level = observed.name, observed.level
                            window.record.family = observed.family
                        elseif p.guid and p.guid ~= sourceGUID then
                            window.record.name, window.record.level, window.record.family = "Unidentified creature", nil, nil
                        end
                    end
                    window.slots[slot] = { id = itemID, link = link, name = name, icon = icon, quality = quality, count = qty, cleared = false }
                end
            end
        end
    end
end

function T:CloseLoot()
    local window = self.window
    self.window = nil
    if not window then return end
    local function finish()
        local pending = self.pending
        local success = window.success or (pending and pending.token == window.token and pending.success)
        if not success then return end
        local record = window.record
        record.items = {}
        for _, loot in pairs(window.slots) do
            if loot.cleared then
                local item = record.items[loot.id]
                if item then item.count = item.count + loot.count else record.items[loot.id] = S.Copy(loot) end
            end
        end
        record.supplement = record.completed or (pending and pending.token == window.token and pending.completed) or false
        local committed = S.Model:Commit(record)
        if committed and pending and pending.token == window.token then pending.completed = true end
    end
    -- Some clients finish the spell after closing an autoloot window.
    C_Timer.After(0.15, finish)
end

function T:Event(event, ...)
    if event == "PLAYER_TARGET_CHANGED" then self:Observe("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then self:Observe("mouseover")
    elseif event == "UNIT_SPELLCAST_SENT" then
        local unit, target, cast, spellID = ...
        if unit == "player" and self:IsSkinning(spellID) then self:Begin(target, cast) end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, cast, spellID = ...
        if unit == "player" and self:IsSkinning(spellID) then self:Success(cast) end
    elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit, cast, spellID = ...
        if unit == "player" and self:IsSkinning(spellID) and self.pending and (not cast or cast == self.pending.castGUID) then
            self.pending = nil
            self.window = nil
        end
    elseif event == "LOOT_READY" or event == "LOOT_OPENED" or event == "LOOT_SLOT_CHANGED" then self:ReadLoot()
    elseif event == "LOOT_SLOT_CLEARED" then
        local slot = ...
        if self.window and self.window.slots[slot] then self.window.slots[slot].cleared = true end
    elseif event == "LOOT_CLOSED" then self:CloseLoot() end
end
