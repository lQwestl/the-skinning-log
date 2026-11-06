local _, S = ...
local U, M, R, L = S.UI, S.Model, S.Research, S.L
S.HUD = {}
local H = S.HUD

-- A fixed three-row display. It creates no per-loot frames, timer chains or
-- saved history; its update script exists only while a message is visible.
S.LootText = { rows = {}, cursor = 0 }
local F = S.LootText
local function updateLootText() F:Tick() end

function F:Build()
    if self.frame then return end
    U:Static(function()
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 235)
        frame:SetSize(math.min(820, UIParent:GetWidth() - 40), 126)
        frame:SetFrameStrata("MEDIUM"); frame:SetClampedToScreen(true)
        for i = 1, 3 do
            local row = CreateFrame("Frame", nil, frame); row:SetSize(frame:GetWidth(), 40)
            row.text = U:Text(row, "", 0, 0, 16, U.c.text, frame:GetWidth()); row.text:SetMaxLines(2); row.text:SetJustifyH("CENTER")
            row:Hide(); self.rows[i] = row
        end
        frame:Hide(); self.frame = frame
    end)
end

function F:Clear()
    if not self.frame then return end
    for _, row in ipairs(self.rows) do
        row.active = nil
        row.text:SetText(""); row:Hide()
    end
    self.frame:SetScript("OnUpdate", nil); self.frame:Hide()
end

function F:Tick()
    local now, count = GetTime(), 0
    for _, row in ipairs(self.rows) do
        if row.active then
            local age = now - row.at
            if age >= 3.5 then
                row.active = nil
                row.text:SetText(""); row:Hide()
            else
                count = count + 1
                row:SetAlpha(M.db.settings.motion and math.min(1, age / 0.12, (3.5 - age) / 0.5) or 1)
            end
        end
    end
    if count == 0 then self.frame:SetScript("OnUpdate", nil); self.frame:Hide() end
end

function F:Display(record)
    if not M.db.settings.lootText then return end
    self:Build()
    for id, item in pairs(record.items) do
        if item.count > 0 then
            self.cursor = self.cursor % 3 + 1
            local row = self.rows[self.cursor]
            row.active, row.at = true, GetTime()
            local label = item.link or ("[" .. (item.name or ("Item " .. id)) .. "]")
            row.text:SetText("|T" .. (item.icon or S.icon) .. ":22|t " .. item.count .. "x " .. label .. "  |cffffd100(" .. (record.name or L("Creatures")) .. ")|r")
            row:SetAlpha(1); row:Show()
        end
    end
    for i = 0, 2 do
        local row = self.rows[(self.cursor - i - 1) % 3 + 1]
        row:ClearAllPoints(); row:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, i * 42)
    end
    self.frame:Show(); self.frame:SetScript("OnUpdate", updateLootText)
end

function S:SkinningSkill()
    local spell = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(8613)
    local name = spell and spell.name or (GetSpellInfo and GetSpellInfo(8613)) or L("Skinning")
    if GetProfessions and GetProfessionInfo then
        for _, index in pairs({ GetProfessions() }) do
            local profession, _, rank, maximum, _, _, lineID = GetProfessionInfo(index)
            if lineID == 393 or profession == name then return rank, maximum end
        end
    end
    local count = C_SkillInfo and C_SkillInfo.GetNumSkillLines or GetNumSkillLines
    local info = C_SkillInfo and C_SkillInfo.GetSkillLineInfo or GetSkillLineInfo
    if not count or not info then return end
    for i = 1, count() do
        local skill, header, _, rank, _, _, maximum = info(i)
        if type(skill) == "table" then
            local data = skill; skill, header, rank, maximum = data.name, data.isHeader, data.rank, data.maxRank
        end
        if not header and (skill == name or skill == L("Skinning")) then return rank, maximum end
    end
end

function H:Build()
    if self.frame then return end
    U:Static(function()
        local f = U:Panel(UIParent, 0, 0, 292, 119)
        f:SetFrameStrata("MEDIUM"); f:SetClampedToScreen(true); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
        self.frame = f; self:Position()
        f:SetScript("OnDragStart", function() f:StartMoving() end)
        f:SetScript("OnDragStop", function() f:StopMovingOrSizing(); U:SavePosition(f, "hudPosition") end)
        U:Section(f, "", 6, 5, 280)
        U:Icon(f, S.icon, 11, 10, 17)
        self.title = U:OneLine(f, "Skinning", 35, 9, 11, U.c.gold, 200)
        self.title:SetHeight(18); self.title:SetJustifyV("MIDDLE")
        self.expand = U:Button(f, "+", 243, 8, 18, 19, function() M.db.settings.hudExpanded = not M.db.settings.hudExpanded; self:Refresh() end)
        U:Tooltip(self.expand, "Expand", { "Recent gathers", "Skill" })
        local hide = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        hide:SetSize(22, 22); hide:SetPoint("TOPLEFT", 263, -6)
        hide:SetScript("OnClick", function() M.db.settings.hud = false; self:Refresh() end)
        U:Tooltip(hide, "Close", { "/tsl tracker" })
        self.totals = U:OneLine(f, "", 12, 39, 12, U.c.text, 205)
        self.clock = U:OneLine(f, "", 227, 40, 10, U.c.muted, 57)
        self.loot = U:Button(f, "", 10, 62, 273, 25, function()
            local recent = M:Session().history[1]; if recent then U:CreatureSheet(recent.key) else U:Open("guide") end
        end)
        self.loot.icon = U:Icon(self.loot, S.icon, 3, 3, 19)
        self.loot.name = U:OneLine(self.loot, "", 28, 6, 11, U.c.text, 207)
        self.loot.qty = U:OneLine(self.loot, "", 238, 6, 11, U.c.gold, 30)
        self.xpFill = U:Bar(f, 12, 96, 268, 0, U.c.blue, 14)
        self.rank = U:OneLine(f, "", 12, 111, 9, U.c.muted, 208)
        self.rate = U:OneLine(f, "", 219, 111, 9, U.c.muted, 66)
        self.goal = CreateFrame("Frame", nil, f); self.goal:SetPoint("TOPLEFT", 12, -132); self.goal:SetSize(268, 32)
        self.goal.name = U:OneLine(self.goal, "", 0, 0, 10, U.c.text, 194)
        self.goal.count = U:OneLine(self.goal, "", 202, 0, 10, U.c.green, 67)
        self.goal.fill = U:Bar(self.goal, 0, 16, 268, 0, U.c.green, 14)
        self.details = CreateFrame("Frame", nil, f); self.details:SetSize(292, 153)
        U:Line(self.details, 12, 1, 268)
        self.skill = U:OneLine(self.details, "", 12, 14, 10, U.c.gold, 268)
        self.skillFill = U:Bar(self.details, 12, 31, 268, 0, U.c.gold, 16)
        self.rows = {}
        for i = 1, 3 do self.rows[i] = U:OneLine(self.details, "", 12, 51 + (i - 1) * 20, 10, U.c.muted, 268) end
        local expedition = U:Button(self.details, "Expedition", 11, 112, 84, 27, function() U:Open("session") end)
        local grounds = U:Button(self.details, "Hunting grounds", 103, 112, 108, 27, function() S.Maps:Open() end)
        local research = U:Button(self.details, "Research", 219, 112, 64, 27, function() U:Open("research") end)
        local shortcutFont = (GameFontNormal and GameFontNormal:GetFont()) or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
        for _, shortcut in ipairs({ expedition, grounds, research }) do shortcut.label:SetFont(shortcutFont, 10, "") end
        local elapsed = 0
        f:SetScript("OnUpdate", function(_, delta) elapsed = elapsed + delta; if elapsed >= 1 then elapsed = 0; self:Tick() end end)
        f:SetScript("OnEnter", function()
            local data = M:Session()
            GameTooltip:SetOwner(f, "ANCHOR_LEFT"); GameTooltip:SetText(L("Expedition"), 0.91, 0.76, 0.43)
            GameTooltip:AddLine(L("Estimated value") .. ": " .. S.Money(M:Value(data)), 0.84, 0.87, 0.79)
            GameTooltip:AddLine(L("Per skin") .. ": " .. string.format("%.2f", data.units / math.max(1, data.skins)), 0.84, 0.87, 0.79)
            GameTooltip:AddLine(L("Session XP") .. ": +" .. (data.xp or 0), 0.65, 0.79, 0.91)
            GameTooltip:AddLine(L("Rates include travel and idle time. Available after one minute."), 0.65, 0.68, 0.61, true)
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function() GameTooltip:Hide() end)
        f:Hide()
    end)
end

function H:Position()
    if self.frame then U:RestorePosition(self.frame, "hudPosition", "RIGHT", -310, 80) end
end

function H:Tick()
    if not self.frame or not self.frame:IsShown() then return end
    local data = M:Session()
    local elapsed = data.skins > 0 and math.max(0, time() - data.start) or 0
    self.clock:SetText(elapsed >= 3600 and S.Duration(elapsed) or string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60))
    self.rate:SetText(elapsed >= 60 and string.format("%.0f /h", data.skins / elapsed * 3600) or "-- /h")
end

function H:Refresh()
    self:Build()
    local settings, data = M.db.settings, M:Session()
    self.frame:SetShown(settings.hud)
    if not settings.hud then return end
    self.frame:SetScale(settings.hudScale)
    local goal, progress, other = M:GoalProgress(); local hasGoal = goal and not other
    local baseHeight = hasGoal and 165 or 127
    self.frame:SetHeight(baseHeight + (settings.hudExpanded and 151 or 0))
    self.title:SetText(S.demo and L("Sample journal") or (settings.enabled and (L("Skinning") .. S.Sep() .. GetZoneText()) or L("Tracking paused")))
    self.totals:SetText(S.Fmt("%d skinned · %d materials", data.skins, data.units))
    self.expand.label:SetText(settings.hudExpanded and "-" or "+")
    local recent = data.history[1]; local best, loot
    if recent then
        for id, item in pairs(recent.items) do if not loot or item.count > loot.count or (item.count == loot.count and id < best) then best, loot = id, item end end
    end
    self.loot.icon:SetTexture(loot and loot.icon or "Interface\\Icons\\Ability_Tracking")
    self.loot.name:SetText(loot and loot.name or L("Your discoveries are waiting")); self.loot.qty:SetText(loot and ("+" .. loot.count) or "")
    local state = R:State(); local rank, nextRank = R:Rank(state.xp)
    self.rank:SetText(L(state.title or rank.name) .. S.Sep() .. state.xp .. " XP")
    U:SetBar(self.xpFill, nextRank and (state.xp - rank.xp) / (nextRank.xp - rank.xp) or 1)
    self.goal:SetShown(hasGoal and true or false)
    if hasGoal then self.goal.name:SetText(goal.name); self.goal.count:SetText(progress .. "/" .. goal.target); U:SetBar(self.goal.fill, progress / goal.target) end
    self.details:SetShown(settings.hudExpanded)
    self.details:ClearAllPoints(); self.details:SetPoint("TOPLEFT", 0, -baseHeight)
    if settings.hudExpanded then
        local skill, maximum = S:SkinningSkill()
        self.skill:SetText(L("Skinning") .. "  " .. (skill and (skill .. "/" .. maximum) or L("unknown")))
        U:SetBar(self.skillFill, skill and maximum > 0 and skill / maximum or 0)
        for i, row in ipairs(self.rows) do
            local h = data.history[i]
            row:SetText(h and (date("%H:%M", h.at) .. "  " .. h.name .. "  +" .. h.units) or "")
        end
    end
    self:Tick()
end

S.noticeQueue = {}
function S:Notice(entry)
    if #self.noticeQueue >= 20 then table.remove(self.noticeQueue, 1) end
    self.noticeQueue[#self.noticeQueue + 1] = entry
    if not self.noticeActive then self:NextNotice() end
end

function S:NextNotice()
    local entry = table.remove(self.noticeQueue, 1)
    self.noticeActive = entry
    if not entry then if self.notice then self.notice:Hide(); self.notice:SetScript("OnUpdate", nil) end; return end
    U:Static(function()
        if not self.notice then
            local f = U:Panel(UIParent, 0, 0, 428, 126)
            f:ClearAllPoints(); f:SetPoint("TOP", UIParent, "TOP", 0, -115); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true)
            f.title = U:Section(f, "", 104, 7, 305)
            f.name = U:Text(f, "", 111, 34, 18, U.c.text, 294); f.name:SetMaxLines(2)
            f.sub = U:OneLine(f, "", 111, 84, 10, U.c.muted, 294)
            f.xp = U:OneLine(f, "", 111, 106, 10, U.c.blue, 294)
            U:Line(f, 111, 100, 294)
            f.art = U:Panel(f, 13, 16, 84, 94)
            f.icon = U:Icon(f.art, nil, 12, 17, 60)
            f.model = CreateFrame("PlayerModel", nil, f.art); f.model:SetPoint("TOPLEFT", 3, -3); f.model:SetSize(78, 88)
            local hit = CreateFrame("Button", nil, f); hit:SetAllPoints()
            hit:SetScript("OnClick", function()
                local e = S.noticeActive
                if e and e.key then U:CreatureSheet(e.key) elseif e and e.kind == "rank" then U:Open("research") else U:Open("session") end
                S:NextNotice()
            end)
            U:Tooltip(hit, "Click to inspect", { "Field journal" })
            local close = U:Button(f, "x", 404, 6, 17, 18, function() S:NextNotice() end)
            close:SetFrameLevel(hit:GetFrameLevel() + 1)
            self.notice = f
        end
        local f = self.notice
        f:ClearAllPoints(); f:SetPoint("TOP", UIParent, "TOP", 0, -115)
        f.title:SetText(L(entry.title)); f.name:SetText(entry.name or ""); f.sub:SetText(entry.subtitle or L("Click to inspect"))
        f.xp:SetText((entry.xp and entry.xp > 0 and ("+" .. entry.xp .. " XP" .. S.Sep(true)) or "") .. L("Click to inspect"))
        f.icon:SetTexture(entry.icon or self:FamilyIcon(entry.family)); U:AssignCreature(f.model, entry, f.icon, 0.5)
        f:SetScale(math.min(1, (UIParent:GetWidth() - 35) / 428))
        local began, token = GetTime(), entry
        f:SetAlpha(M.db.settings.motion and 0 or 1); f:Show()
        f:SetScript("OnUpdate", M.db.settings.motion and function(frame)
            local t = GetTime() - began
            local alpha = math.min(1, t / 0.25, math.max(0, (5.5 - t) / 0.6))
            frame:SetAlpha(alpha); frame:ClearAllPoints(); frame:SetPoint("TOP", UIParent, "TOP", 0, -115 + 12 * (1 - math.min(1, t / 0.25)))
        end or nil)
        C_Timer.After(5.5, function() if S.noticeActive == token then S:NextNotice() end end)
        if M.db.settings.sound and PlaySound and SOUNDKIT then
            local sound = SOUNDKIT.UI_EPICLOOT_TOAST or SOUNDKIT.IG_QUEST_LOG_OPEN
            if sound then PlaySound(sound, "SFX") end
        end
    end)
end

function S:PreviewNotice()
    local creature = M:Creatures("", "all", "recent")[1]
    self:Notice({ kind = "discovery", title = "New discovery", name = creature and creature.name or L("Your next discovery starts with one skin."),
        key = creature and creature.key, npcID = creature and creature.npcID, family = creature and creature.family,
        subtitle = L("Preview only · no progress awarded") })
end

function S:Welcome(force, research)
    if not force and M.db.settings.onboardingVersion == 2 then return end
    if not force and InCombatLockdown and InCombatLockdown() then self.welcomePending = true; return end
    U:Static(function()
        if not self.welcome then
            local f = U:Panel(UIParent, 0, 0, 566, 478)
            f:ClearAllPoints(); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true)
            f.title = U:Text(f, "", 23, 22, 21, U.c.gold, 515)
            f.sub = U:Text(f, "", 24, 58, 12, U.c.muted, 510)
            f.steps = {}
            for i = 1, 3 do
                local y = 100 + (i - 1) * 85
                local icon = U:Icon(f, S.icon, 25, y + 2, 39)
                local title = U:Text(f, "", 80, y, 15, U.c.gold, 458)
                local body = U:Text(f, "", 80, y + 26, 12, U.c.text, 458)
                f.steps[i] = { icon = icon, title = title, body = body }
            end
            f.credit = U:OneLine(f, "", 24, 363, 10, U.c.muted, 516)
            f.switch = U:Button(f, "How XP works", 24, 391, 165, 27, function() S:Welcome(true, not f.research) end)
            U:Button(f, "Sample journal", 201, 391, 165, 27, function()
                if not S.demo then S:ToggleDemo() end
                M.db.settings.onboardingVersion = 2; f:Hide(); U:Open("guide"); H:Refresh()
            end)
            U:Button(f, "Preview discovery", 378, 391, 164, 27, function() f:Hide(); S:PreviewNotice() end)
            U:Button(f, "Open journal", 24, 434, 248, 29, function() M.db.settings.onboardingVersion = 2; f:Hide(); U:Open(f.research and "research" or "guide") end)
            U:Button(f, "Start exploring", 286, 434, 256, 29, function() M.db.settings.onboardingVersion = 2; f:Hide(); M.db.settings.hud = true; H:Refresh() end, true)
            local close = CreateFrame("Button", nil, f, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -2, -2)
            close:SetScript("OnClick", function() M.db.settings.onboardingVersion = 2; f:Hide() end)
            f:SetScript("OnHide", function() M.db.settings.onboardingVersion = 2 end)
            _G.SkinningLogSolWelcome = f; table.insert(UISpecialFrames, "SkinningLogSolWelcome"); self.welcome = f
        end
        local f = self.welcome; f.research = research
        f.title:SetText(L(research and "How XP works" or "Welcome to your field journal"))
        f.sub:SetText(L(research and "This is addon research XP. It does not change character level or profession skill." or "Your next discovery starts with one skin."))
        local steps
        if research then
            steps = {
                { "Interface\\Icons\\Ability_Tracking", "Successful skin", "5 XP per skin. New species: +40 XP. New zone: +25 XP. Every recorded creature starts its own mastery journey." },
                { "Interface\\Icons\\INV_Misc_Book_09", "Research milestones", "10 / 50 / 100 skins of a species award +30 / 75 / 150 XP. Earn ranks, badges and journal titles as your research grows." },
                { S.icon, "Collection goal", "Goals of 25+ materials grant 25 XP, up to twice per day. Goals count only new loot. Discoveries and rank rewards persist between adventures." },
            }
        else
            steps = {
                { S.icon, "Skin a creature", "Collect its loot. Your journal records the creature, materials and your location automatically." },
                { "Interface\\Icons\\Ability_Hunter_BeastCall", "Inspect your discovery", "Open a creature card to study its drops, build mastery and return to its hunting grounds." },
                { "Interface\\Icons\\INV_Misc_Map_01", "Choose your next goal", "Pin a material goal, earn research XP and follow your progress in the compact live tracker." },
            }
        end
        for i, step in ipairs(steps) do f.steps[i].icon:SetTexture(step[1]); f.steps[i].title:SetText(L(step[2])); f.steps[i].body:SetText(L(step[3])) end
        local credit = R:State().migratedXP or 0
        f.credit:SetText(credit > 0 and S.Fmt("%d XP credited from earlier observations", credit) or ("/tsl" .. S.Sep(true) .. "/tsl tracker" .. S.Sep(true) .. "/tsl here"))
        f.switch.label:SetText(L(research and "First steps" or "How XP works"))
        f:SetScale(math.min(1, (UIParent:GetWidth() - 35) / 566, (UIParent:GetHeight() - 35) / 478)); f:Show()
    end)
end
