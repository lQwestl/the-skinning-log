local _, S = ...
local U, M, L, R = S.UI, S.Model, S.L, S.Research
local function sortedItems(items)
    local result = {}
    for id, item in pairs(items) do result[#result + 1] = { id = id, item = item } end
    table.sort(result, function(a, b) if a.item.count ~= b.item.count then return a.item.count > b.item.count end return a.id < b.id end)
    return result
end

function U:Model(parent, c, x, y, w, h)
    local bg = self:Panel(parent, x, y, w, h, { 0.12, 0.14, 0.105, 1 })
    local fallback = self:Icon(bg, S:FamilyIcon(c.family), w / 2 - 20, h / 2 - 20, 40)
    if c.npcID then
        local model = self:Acquire("creaturemodel", bg, function() return CreateFrame("PlayerModel", nil, bg) end)
        model:SetPoint("TOPLEFT", 4, -4); model:SetSize(w - 8, h - 8)
        self:AssignCreature(model, c, fallback, 0.45)
        -- An unavailable NPC model leaves the family emblem visible beneath it.
    end
    return bg
end

function U:Guide()
    local data, p = M:Data(), self.content
    self.footer:SetText(L("Frequencies use collected loot. Small samples vary."))
    local filters = { { "all", "All creatures" }, { "favorites", "Favorites" }, { "mastered", "Mastered" } }
    self:Dropdown(p, self.filter == "all" and "All creatures" or (self.filter == "favorites" and "Favorites" or "Mastered"),
        332, 0, 185, filters, self.filter, function(v) self.filter = v; self.page = 1; self:Refresh() end)
    local choices = { { "yield", "Most materials" }, { "average", "Yield per skin" }, { "skins", "Most skinned" }, { "recent", "Recently seen" }, { "name", "Name" } }
    local names = { yield = "Most materials", average = "Yield per skin", skins = "Most skinned", recent = "Recently seen", name = "Name" }
    self:Dropdown(p, names[self.sort], 528, 0, 198, choices, self.sort, function(v) self.sort = v; self.page = 1; self:Refresh() end)
    self:Button(p, "Research", 737, 0, 155, 28, function() self:SelectTab("research") end)
    if data.skins == 0 then self:Empty(p, "Your discoveries are waiting", "Skin a creature and collect its loot to begin. You can explore a separate sample journal in Help.", 90); return end
    local creatures = M:Creatures(self.search, self.filter, self.sort)
    self.page = math.min(self.page, math.max(1, math.ceil(#creatures / 7)))
    if not self.selected or not data.creatures[self.selected] then self.selected = creatures[1] and creatures[1].key end
    local list = self:Panel(p, -3, 37, 316, 379)
    for i = 1, 7 do
        local c = creatures[(self.page - 1) * 7 + i]
        if c then
            local row = self:Button(list, "", 3, 5 + (i - 1) * 51, 310, 46, function() self.selected = c.key; self.dropPage = 1; self:Refresh() end, self.selected == c.key)
            self:Icon(row, S:FamilyIcon(c.family), 8, 8, 30)
            self:OneLine(row, (M.db.favorites[c.key] and "|cffe6c16c* |r" or "") .. c.name, 47, 7, 12, self.c.text, 253)
            self:OneLine(row, L(S.Rank(c.skins)) .. " · " .. S.N(c.skins, "skin"), 47, 27, 10, self.c.muted, 192)
            self:OneLine(row, tostring(c.units), 260, 26, 11, self.c.gold, 40)
            self:Tooltip(row, c.name, { S.Fmt("%d creatures skinned", c.skins), S.Fmt("%d materials collected", c.units),
                L("Yield per skin") .. ": " .. string.format("%.2f", c.units / math.max(1, c.skins)) })
        end
    end
    if #creatures == 0 then self:Text(p, "No matching entries", 12, 65, 16, self.c.gold, 280); self:Text(p, "Try a different search or filter.", 12, 94, 12, self.c.muted, 280) end
    local c = self.selected and data.creatures[self.selected]
    if c then self:CreatureDetail(p, c, data) end
    self:Pagination(p, #creatures, 7, 431)
end

function U:CreatureDetail(parent, c, data)
    local d = self:Panel(parent, 332, 42, 560, 374)
    local rank, progress, nextCount = S.Rank(c.skins)
    self:Section(d, c.family or "Creatures", 9, 9, 354)
    local name = self:Text(d, c.name, 16, 37, 20, self.c.text, 350); name:SetMaxLines(2)
    local level = c.levelMin and c.levelMin > 0 and tostring(c.levelMin) or "?"
    if c.levelMax and c.levelMax ~= c.levelMin then level = level .. "–" .. c.levelMax end
    self:Text(d, S.Fmt("Level %s", level), 17, 89, 11, self.c.muted)
    self:Button(d, M.db.favorites[c.key] and "Favorited" or "Favorite", 423, 12, 121, 25, function()
        if S.demo then return S:Print(L("Exit the sample journal to save changes.")) end
        M.db.favorites[c.key] = not M.db.favorites[c.key]; self:Refresh()
    end, M.db.favorites[c.key])
    self:Model(d, c, 389, 46, 155, 143)
    self:Text(d, L(rank), 16, 115, 13, self.c.gold)
    self:Bar(d, 16, 134, 348, progress / nextCount, self.c.gold, 18)
    self:OneLine(d, c.skins >= 100 and L("Master") or S.Fmt("%d more skins to %s", nextCount - c.skins, L(S.Rank(nextCount))), 16, 155, 10, self.c.muted, 350)
    self:OneLine(d, S.Fmt("First recorded %s", date("%d.%m.%Y", c.first)), 16, 174, 10, self.c.muted, 355)
    self:Line(d, 16, 204, 528)
    self:Text(d, tostring(c.skins), 18, 215, 21, self.c.text)
    self:Text(d, "Skinned", 18, 241, 10, self.c.muted)
    self:Text(d, tostring(c.units), 143, 215, 21, self.c.text)
    self:Text(d, "Materials", 143, 241, 10, self.c.muted)
    self:Text(d, string.format("%.2f", c.units / math.max(1, c.skins)), 270, 215, 21, self.c.gold)
    self:Text(d, "Per skin", 270, 241, 10, self.c.muted)
    local value = 0; for id, item in pairs(c.items) do value = value + M:Price(id) * item.count end
    self:Text(d, S.Money(value), 420, 215, 21, self.c.text)
    self:Text(d, "Estimated value", 420, 241, 10, self.c.muted)
    -- The rest of the card opens into its own detail sheet, keeping the journal compact.
    self:Button(d, "Observed drops", 16, 273, 166, 29, function() self:CreatureSheet(c.key) end)
    local bestMap, best
    for id, z in pairs(c.zones) do if not best or z.skins > best.skins then best, bestMap = z, id end end
    self:Button(d, "Show on map", 197, 273, 166, 29, function()
        S.Maps:SetFilter("creature", c.key); S.Maps:Open(bestMap)
    end)
    self:Button(d, "Research", 378, 273, 166, 29, function() self:SelectTab("research") end)
    self:OneLine(d, best and (best.name .. " · " .. S.N(best.skins, "skin")) or L("Unknown zone"), 17, 315, 11, self.c.muted, 528)
    local drops, summary = sortedItems(c.items), {}
    for i = 1, math.min(2, #drops) do
        local item = data.items[drops[i].id]
        summary[#summary + 1] = drops[i].item.count .. "× " .. item.name
    end
    self:OneLine(d, table.concat(summary, " · "), 17, 341, 10, self.c.gold, 526)
end

function U:CreatureSheet(key)
    self:Static(function()
        local c, data = M:Data().creatures[key], M:Data()
        if not c then return end
        if not self.sheet then
            local f = self:Panel(UIParent, 0, 0, 518, 590)
            f:ClearAllPoints(); f:SetPoint("CENTER", UIParent, "CENTER", 180, 0); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true)
            f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
            f:SetScript("OnDragStart", function() f:StartMoving() end); f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
            f.title = self:Text(f, "", 20, 18, 19, self.c.gold, 449); f.title:SetMaxLines(2)
            f.meta = self:Text(f, "", 20, 67, 11, self.c.muted, 450)
            f.modelBack = self:Panel(f, 20, 91, 146, 151)
            f.family = self:Icon(f.modelBack, nil, 48, 49, 50)
            f.model = CreateFrame("PlayerModel", nil, f.modelBack); f.model:SetPoint("TOPLEFT", 3, -3); f.model:SetSize(140, 145)
            f.stats = self:Text(f, "", 185, 102, 13, self.c.text, 304)
            self:Text(f, "Observed drops", 20, 263, 11, self.c.gold)
            f.dropRows = {}
            for i = 1, 4 do
                local row = self:Button(f, "", 20, 287 + (i - 1) * 34, 478, 30, nil)
                row.icon = self:Icon(row, nil, 4, 4, 22)
                row.name = self:OneLine(row, "", 35, 8, 12, self.c.text, 275)
                row.rate = self:OneLine(row, "", 330, 8, 11, self.c.muted, 140); f.dropRows[i] = row
            end
            f.more = self:Button(f, "", 376, 433, 122, 24, function() self.sheetDropPage = (self.sheetDropPage or 1) + 1; self:CreatureSheet(f.key) end)
            f.ground = self:OneLine(f, "", 20, 469, 11, self.c.muted, 478)
            f.note = self:Input(f, 20, 495, 353, "Field note...", function(text) self.noteDrafts = self.noteDrafts or {}; self.noteDrafts[f.key] = text end)
            f.note:SetMaxLetters(180)
            f.save = self:Button(f, "Save note", 383, 495, 115, 29, function()
                if S.demo then return S:Print(L("Exit the sample journal to save changes.")) end
                M.db.notes[f.key] = f.note:GetText(); if self.noteDrafts then self.noteDrafts[f.key] = nil end
                f.note:ClearFocus(); S:Print(L("Field note saved."))
            end)
            f.mapButton = self:Button(f, "Show on map", 20, 546, 230, 29, function()
                S.Maps:SetFilter("creature", f.key); S.Maps:Open(f.mapID); f:Hide()
            end)
            f.bottomClose = self:Button(f, "Close", 267, 546, 231, 29, function() f:Hide() end)
            local close = CreateFrame("Button", nil, f, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -2, -2); close:SetScript("OnClick", function() f:Hide() end)
            _G.SkinningLogSolSheet = f; table.insert(UISpecialFrames, "SkinningLogSolSheet"); self.sheet = f
        end
        local f = self.sheet
        if f.key ~= key then self.sheetDropPage = 1 end
        f.key = key
        local rank, _, goal = S.Rank(c.skins)
        f.title:SetText(c.name); f.meta:SetText((c.family or L("Creatures")) .. " · " .. L(rank))
        f.family:SetTexture(S:FamilyIcon(c.family)); self:AssignCreature(f.model, c, f.family, 0.4)
        f.stats:SetText(S.Fmt("%d creatures skinned", c.skins) .. "\n\n" .. S.Fmt("%d materials collected", c.units) .. "\n\n" .. L("Per skin") .. ": " .. string.format("%.2f", c.units / math.max(1, c.skins)) .. "\n\n" .. (c.skins < 100 and S.Fmt("%d more skins to %s", goal - c.skins, L(S.Rank(goal))) or L("Master")))
        local drops = sortedItems(c.items); local pages = math.max(1, math.ceil(#drops / 4))
        self.sheetDropPage = ((self.sheetDropPage or 1) - 1) % pages + 1
        for i, row in ipairs(f.dropRows) do
            local drop = drops[(self.sheetDropPage - 1) * 4 + i]; row:SetShown(drop ~= nil)
            if drop then
                local item = data.items[drop.id]; row.icon:SetTexture(item.icon or S.icon); row.name:SetText(S:ItemLabel(item))
                row.rate:SetText(string.format("%d  ·  %.0f%%", drop.item.count, drop.item.drops / math.max(1, c.skins) * 100))
                self:Tooltip(row, item.name, { S.Fmt("%d skins sampled", c.skins), L("Frequencies use collected loot. Small samples vary.") })
                row:SetScript("OnClick", function() self.material = drop.id; self:Open("materials"); f:Hide() end)
            end
        end
        f.more:SetShown(pages > 1); f.more.label:SetText(S.Fmt("Page %d / %d", self.sheetDropPage, pages) .. " >")
        local visibleRows = math.min(4, #drops - (self.sheetDropPage - 1) * 4)
        local groundY = 287 + visibleRows * 34 + (pages > 1 and 35 or 13)
        f.more:ClearAllPoints(); f.more:SetPoint("TOPLEFT", 376, -287 - visibleRows * 34 - 5)
        f.ground:ClearAllPoints(); f.ground:SetPoint("TOPLEFT", 20, -groundY)
        f.note:ClearAllPoints(); f.note:SetPoint("TOPLEFT", 20, -groundY - 27)
        f.save:ClearAllPoints(); f.save:SetPoint("TOPLEFT", 383, -groundY - 27)
        f.mapButton:ClearAllPoints(); f.mapButton:SetPoint("TOPLEFT", 20, -groundY - 78)
        f.bottomClose:ClearAllPoints(); f.bottomClose:SetPoint("TOPLEFT", 267, -groundY - 78)
        f:SetHeight(groundY + 121)
        local best
        for id, z in pairs(c.zones) do if not best or z.skins > best.skins then best = z; f.mapID = id end end
        f.ground:SetText(best and (best.name .. " · " .. S.N(best.skins, "skin")) or L("Unknown zone"))
        f.note:SetText(S.demo and "" or (self.noteDrafts and self.noteDrafts[key]) or M.db.notes[key] or "")
        f:SetScale(math.min(M.db.settings.journalScale, (UIParent:GetHeight() - 30) / f:GetHeight())); f:Show()
    end)
end

function U:Materials()
    local data, p = M:Data(), self.content
    self.footer:SetText(L("Prices are estimates from local Auctionator data or vendor prices."))
    if data.units == 0 then self:Empty(p, "Your discoveries are waiting", "Skin a creature and collect its loot to begin. You can explore a separate sample journal in Help.", 80); return end
    local items = sortedItems(data.items)
    if self.materialSearch and self.materialSearch ~= "" then
        local filtered = {}
        for _, row in ipairs(items) do if row.item.name:lower():find(self.materialSearch:lower(), 1, true) then filtered[#filtered + 1] = row end end
        items = filtered
    end
    if #items == 0 then self:Empty(p, "No matching entries", "Try a different search or filter.", 80); return end
    self.page = math.min(self.page, math.max(1, math.ceil(#items / 7)))
    if not self.material or not data.items[self.material] then self.material = items[1].id; self.sourcePage = 1 end
    local list = self:Panel(p, -3, 31, 356, 385)
    for i = 1, 7 do
        local entry = items[(self.page - 1) * 7 + i]
        if entry then
            local item, id = entry.item, entry.id; local price, source = M:Price(id)
            local row = self:Button(list, "", 3, 4 + (i - 1) * 51, 350, 46, function() self.material = id; self.sourcePage = 1; self:Refresh() end, self.material == id)
            self:Icon(row, item.icon, 8, 8, 30); self:OneLine(row, S:ItemLabel(item), 48, 7, 12, self.c.text, 252)
            self:Text(row, L(source) .. " · " .. S.Money(price * item.count), 48, 27, 10, self.c.muted)
            self:Text(row, tostring(item.count), 306, 26, 12, self.c.gold)
            row:SetScript("OnEnter", function(owner)
                GameTooltip:SetOwner(owner, "ANCHOR_RIGHT"); GameTooltip:SetHyperlink("item:" .. id)
                GameTooltip:AddLine(L("Collected") .. ": " .. item.count, 0.88, 0.83, 0.64); GameTooltip:Show()
            end)
        end
    end
    local item, d = data.items[self.material], self:Panel(p, 370, 0, 522, 416)
    self:Icon(d, item.icon, 16, 17, 52)
    local title = self:Text(d, S:ItemLabel(item), 83, 18, 20, self.c.gold, 420); title:SetMaxLines(2)
    self:Text(d, S.N(item.count, "material") .. " · " .. S.Count(item.creatures) .. " " .. L("Creatures"), 84, 68, 11, self.c.muted, 415)
    self:Line(d, 16, 97, 490)
    self:Section(d, "Best sources", 9, 105, 503)
    local yieldLabel = self:OneLine(d, "Yield per skin", 380, 109, 10, self.c.muted, 110)
    yieldLabel:SetHeight(18); yieldLabel:SetJustifyV("MIDDLE"); yieldLabel:SetJustifyH("RIGHT")
    local sources = {}
    for key, count in pairs(item.creatures) do
        local c = data.creatures[key]
        sources[#sources + 1] = { c = c, count = count, average = count / math.max(1, c.skins) }
    end
    table.sort(sources, function(a, b) if a.average ~= b.average then return a.average > b.average end return a.count > b.count end)
    local pages = math.max(1, math.ceil(#sources / 4)); self.sourcePage = math.min(self.sourcePage or 1, pages)
    for i = 1, 4 do
        local source = sources[(self.sourcePage - 1) * 4 + i]
        if source then
            local row = self:Button(d, "", 16, 139 + (i - 1) * 45, 490, 39, function() self:CreatureSheet(source.c.key) end)
            self:Icon(row, S:FamilyIcon(source.c.family), 7, 7, 25)
            self:OneLine(row, source.c.name, 43, 5, 12, self.c.text, 351)
            self:Text(row, S.Fmt("%d skins sampled", source.c.skins), 43, 24, 10, self.c.muted)
            self:Text(row, string.format("%.2f", source.average), 421, 10, 16, self.c.gold)
        end
    end
    if pages > 1 then self:Button(d, S.Fmt("Page %d / %d", self.sourcePage, pages) .. " >", 16, 327, 154, 23, function() self.sourcePage = self.sourcePage % pages + 1; self:Refresh() end) end
    self:Button(d, "Show on map", 345, 327, 161, 23, function() S.Maps:SetFilter("item", self.material); S.Maps:Open() end)
    self:Text(d, "Collection goal", 16, 362, 10, self.c.gold)
    local input = self:Input(d, 157, 355, 91, "100", function(text) self.goalDraft = text end)
    input:SetNumeric(true); input:SetMaxLetters(6); input:SetText(self.goalDraft or "100")
    self:Button(d, "Set goal", 263, 355, 243, 29, function()
        if S.demo then return S:Print(L("Exit the sample journal to save changes.")) end
        local target = tonumber(input:GetText())
        if not target or target < 1 or target > 999999 then return S:Print(L("Enter a target from 1 to 999999.")) end
        M:Goal(item, math.floor(target)); self:SelectTab("session")
    end)
    self:Text(d, "Goals of 25+ materials grant 25 XP, up to twice per day.", 16, 395, 9, self.c.muted, 490)
    self:Pagination(p, #items, 7, 431)
end

function U:Stat(parent, label, value, x, y, width, hint)
    local panel = self:Panel(parent, x, y, width, 76)
    self:Text(panel, label, 14, 12, 10, self.c.muted)
    local text = self:OneLine(panel, tostring(value), 14, 34, 23, self.c.text, width - 26)
    if hint then self:Tooltip(panel, label, { hint }) end
    return text
end

function U:GoalPanel(parent, x, y, width)
    local g = self:Panel(parent, x, y, width, 87)
    local goal, progress, other = M:GoalProgress()
    self:Text(g, "Collection goal", 15, 12, 10, self.c.gold)
    if goal then
        self:OneLine(g, goal.name .. "  " .. progress .. "/" .. goal.target, 15, 34, 17, self.c.text, width - 175)
        self:Bar(g, 15, 61, width - 181, progress / goal.target, self.c.green)
        local b = self:Button(g, "Clear goal", width - 150, 30, 133, 29, function()
            if not S.demo then M.db.goal = nil; self:Refresh(); S.HUD:Refresh() end
        end)
        self:Tooltip(b, "Collection goal", { other and goal.character or "Only new loot on the character that set this goal counts.", "Goals of 25+ materials grant 25 XP, up to twice per day." })
    else
        self:OneLine(g, "Choose your next goal", 15, 37, 16, self.c.text, width - 180)
        self:Button(g, "Set goal", width - 150, 30, 133, 29, function() self:SelectTab("materials") end)
    end
end

function U:Expedition()
    local p, data = self.content, M:Session()
    self.footer:SetText(L("Rates include travel and idle time. Available after one minute."))
    self:Stat(p, "Skinned", data.skins, 0, 0, 212)
    self:Stat(p, "Materials", data.units, 227, 0, 212)
    self.rateLabel = self:Stat(p, "Skins / hour", "--", 454, 0, 212)
    self.clockLabel = self:Stat(p, "Elapsed", "00:00:00", 681, 0, 211)
    self:GoalPanel(p, 0, 92, 892)
    self:Button(p, "Recent gathers", 0, 195, 170, 28, function() self.sessionHistory = false; self.page = 1; self:Refresh() end, not self.sessionHistory)
    self:Button(p, "Session history", 180, 195, 170, 28, function() self.sessionHistory = true; self.page = 1; self:Refresh() end, self.sessionHistory)
    self:Text(p, L("Session XP") .. ": +" .. (data.xp or 0), 374, 204, 12, self.c.gold)
    self:Button(p, "New expedition", 709, 195, 183, 28, function()
        if S.demo then return S:Print(L("Exit the sample journal to save changes.")) end
        M:NewSession(); self:Refresh()
    end)
    local history = data.history
    if self.sessionHistory then
        history = {}
        for _, h in ipairs(M.db.sessions or {}) do if h.character == M.character then history[#history + 1] = h end end
    end
    self.page = math.min(self.page, math.max(1, math.ceil(#history / 5)))
    for i = 1, 5 do
        local h = history[(self.page - 1) * 5 + i]
        if h then
            local row = self:Button(p, "", 0, 241 + (i - 1) * 35, 892, 31, function() if h.key then self:CreatureSheet(h.key) end end)
            self:Text(row, date(self.sessionHistory and "%d.%m. %H:%M" or "%H:%M", h.at or h.start), 9, 9, 11, self.c.muted)
            self:OneLine(row, self.sessionHistory and S.Fmt("%d creatures skinned", h.skins) or h.name, 135, 8, 12, self.c.text, 300)
            self:OneLine(row, self.sessionHistory and S.Duration(h.duration) or h.zone, 461, 9, 11, self.c.muted, 240)
            self:OneLine(row, self.sessionHistory and (h.xp and ("+" .. h.xp .. " XP") or "-- XP") or ("+" .. S.N(h.units, "material")), 735, 8, 11, self.c.gold, 145)
        end
    end
    if #history == 0 then self:Text(p, self.sessionHistory and "No completed expeditions yet." or "Your next discovery starts with one skin.", 15, 259, 14, self.c.muted, 850) end
    self:Pagination(p, #history, 5, 431)
end

function U:Research()
    local p = self.content
    local data = S.demo and M:Data() or M.db.characters[M.character]
    local state = R:State(); local rank, nextRank, level = R:Rank(state.xp)
    self.footer:SetText(L("This is addon research XP. It does not change character level or profession skill."))
    local ladder = self:Panel(p, 0, 0, 356, 416)
    self:Icon(ladder, rank.icon, 16, 17, 53)
    self:Text(ladder, "Your rank", 84, 17, 10, self.c.muted)
    self:OneLine(ladder, L(rank.name), 84, 37, 18, self.c.gold, 253)
    self:Text(ladder, state.xp .. " XP", 84, 66, 11, self.c.text)
    self:Bar(ladder, 16, 91, 322, nextRank and (state.xp - rank.xp) / (nextRank.xp - rank.xp) or 1, self.c.blue)
    for i, r in ipairs(R.ranks) do
        local y = 114 + (i - 1) * 35
        local row = self:Button(ladder, "", 13, y, 330, 31, function()
            if S.demo then return end
            if level >= i then state.title = r.name; self:Refresh(); S.HUD:Refresh() end
        end, state.title == r.name or (not state.title and level == i))
        self:OneLine(row, (level >= i and "|cffe8c16c" or "|cff8b8f81") .. L(r.name) .. "|r", 9, 9, 11, self.c.text, 240)
        self:OneLine(row, tostring(r.xp), 266, 9, 10, self.c.muted, 55)
        self:Tooltip(row, r.name, { r.xp .. " XP", "Unlocks an addon journal title.", level >= i and "Wear title" or "Locked" })
    end
    local milestones = self:Panel(p, 372, 0, 520, 416)
    self:Section(milestones, "Research milestones", 9, 9, 502)
    for i, badge in ipairs(R:Badges(data)) do
        local bx, by = 14 + ((i - 1) % 2) * 253, 49 + math.floor((i - 1) / 2) * 54
        local earned = badge.value >= badge.target
        local b = self:Panel(milestones, bx, by, 239, 47)
        self:Icon(b, badge.icon, 8, 8, 30)
        self:OneLine(b, badge.name, 47, 8, 11, earned and self.c.gold or self.c.text, 185)
        self:Text(b, earned and L("Earned") or (badge.value .. "/" .. badge.target), 47, 27, 10, self.c.muted)
    end
    self:Text(milestones, "Next fieldwork", 16, 284, 11, self.c.gold)
    local creature, remaining = R:NextCreature(data)
    if creature then
        self:OneLine(milestones, creature.name, 16, 307, 15, self.c.text, 480)
        self:Text(milestones, S.Fmt("%d more skins to %s", remaining, L(S.Rank(creature.skins + remaining))), 16, 331, 11, self.c.muted, 350)
        self:Button(milestones, "Open journal", 340, 327, 162, 28, function() self:OpenCreature(creature.key) end)
    else self:Text(milestones, "Observe a new species", 16, 309, 14, self.c.text) end
    self:Text(milestones, L("New species") .. " +40 XP  ·  " .. L("New zone") .. " +25 XP", 16, 376, 11, self.c.gold, 485)
    local b = self:Button(p, "How XP works", 0, 431, 180, 28, function() S:Welcome(true, true) end)
    self:Tooltip(b, "How XP works", { L("Successful skin") .. ": 5 XP", L("New species") .. ": +40 XP", L("New zone") .. ": +25 XP", "10 / 50 / 100 skins: +30 / 75 / 150 XP", "Goals of 25+ materials grant 25 XP, up to twice per day." })
    self:OneLine(p, state.migratedXP and state.migratedXP > 0 and S.Fmt("%d XP credited from earlier observations", state.migratedXP) or "", 200, 440, 10, self.c.muted, 690)
end

function U:Settings()
    local p, settings = self.content, M.db.settings
    self.footer:SetText(S.title .. "  " .. S.version .. "   ·   /tsl help")
    local options = {
        { "enabled", "Record skinning" }, { "hud", "Live tracker" }, { "announce", "Discovery notifications" },
        { "worldPins", "World map pins" }, { "miniPins", "Minimap gathering pins" },
        { "minimap", "Minimap journal button" }, { "tooltips", "Creature tooltip notes" },
        { "sound", "Notification sounds" }, { "motion", "Animated notifications" }, { "lootText", "Skin loot notifications" },
    }
    for i, option in ipairs(options) do
        local x, y = ((i - 1) % 2) * 454, math.floor((i - 1) / 2) * 62
        local card = self:Panel(p, x, y, 438, 51)
        self:OneLine(card, option[2], 13, 18, 12, self.c.text, 322)
        self:Button(card, settings[option[1]] and "On" or "Off", 345, 11, 79, 29, function()
            settings[option[1]] = not settings[option[1]]
            if option[1] == "lootText" and not settings.lootText then S.LootText:Clear() end
            if S.minimap then S.minimap:SetShown(settings.minimap) end
            if S.HUD then S.HUD:Refresh() end
            if S.Maps then S.Maps:Dirty() end
            self:Refresh()
        end, settings[option[1]])
    end
    self:Text(p, "Journal size", 11, 330, 12, self.c.gold)
    self:Text(p, string.format("%.0f%%", settings.journalScale * 100), 207, 330, 12, self.c.text)
    self:Button(p, "-", 277, 321, 66, 29, function() settings.journalScale = math.max(0.65, settings.journalScale - 0.05); self:Scale(); self:Refresh() end)
    self:Button(p, "+", 355, 321, 66, 29, function() settings.journalScale = math.min(1.2, settings.journalScale + 0.05); self:Scale(); self:Refresh() end)
    self:Text(p, "Tracker size", 465, 330, 12, self.c.gold)
    self:Text(p, string.format("%.0f%%", settings.hudScale * 100), 661, 330, 12, self.c.text)
    self:Button(p, "-", 731, 321, 66, 29, function() settings.hudScale = math.max(0.7, settings.hudScale - 0.1); S.HUD:Refresh(); self:Refresh() end)
    self:Button(p, "+", 809, 321, 66, 29, function() settings.hudScale = math.min(1.5, settings.hudScale + 0.1); S.HUD:Refresh(); self:Refresh() end)
    self:Button(p, S.demo and "Exit sample" or "Sample journal", 0, 377, 211, 32, function() S:ToggleDemo(); S.HUD:Refresh(); S.Maps:Dirty() end)
    self:Button(p, "Reset positions", 227, 377, 211, 32, function()
        settings.journalPosition, settings.hudPosition = nil, nil; self:RestorePosition(self.frame, "journalPosition"); S.HUD:Position()
    end)
    self:Button(p, "Copy CSV", 454, 377, 211, 32, function() self:Export() end)
    self:Button(p, "Help", 681, 377, 211, 32, function() S:Welcome(true) end)
end
