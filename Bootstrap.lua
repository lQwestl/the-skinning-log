local addonName, S = ...
function S:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd9ba73The Skinning Log|r  " .. tostring(message))
end

function S:CreateMinimap()
    local b = CreateFrame("Button", "SkinningLogSolMinimap", Minimap)
    b:SetSize(31, 31); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(9)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(20, 20); b.icon:SetPoint("TOPLEFT", 7, -6)
    b.icon:SetTexture(self.icon); b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    if b.CreateMaskTexture and b.icon.AddMaskTexture then
        b.mask = b:CreateMaskTexture()
        b.mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        b.mask:SetAllPoints(b.icon); b.icon:AddMaskTexture(b.mask)
    elseif SetPortraitToTexture then SetPortraitToTexture(b.icon, self.icon) end
    b.border = b:CreateTexture(nil, "OVERLAY")
    b.border:SetSize(54, 54); b.border:SetPoint("TOPLEFT"); b.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    b:SetScript("OnMouseDown", function() b.icon:SetVertexColor(0.7, 0.7, 0.7) end)
    b:SetScript("OnMouseUp", function() b.icon:SetVertexColor(1, 1, 1) end)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    local function position()
        local angle = math.rad(S.Model.db.settings.minimapAngle)
        local radius = Minimap:GetWidth() / 2 + 8
        b:ClearAllPoints(); b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end
    b:SetScript("OnClick", function(_, button)
        if button == "RightButton" then S.Maps:Open() else S.UI:Toggle() end
    end)
    b:SetScript("OnDragStart", function()
        b:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            S.Model.db.settings.minimapAngle = math.deg(math.atan2(y / scale - cy, x / scale - cx))
            position()
        end)
    end)
    b:SetScript("OnDragStop", function() b:SetScript("OnUpdate", nil) end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:SetText(S.title, 0.85, 0.73, 0.45)
        GameTooltip:AddLine(S.L("Left click: journal · Right click: world map · Drag: move"), 0.8, 0.87, 0.8, true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.minimap = b; position(); b:SetShown(self.Model.db.settings.minimap)
end

function S:CreatureTooltip(tooltip, data)
    local M, L = self.Model, self.L
    if tooltip ~= GameTooltip or not M.db or not M.db.settings.tooltips then return end
    local guid = data and data.guid
    if not guid then local _, unit = tooltip:GetUnit(); guid = unit and UnitGUID(unit) end
    local id = self.Tracker:NPCID(guid)
    local observed = M:Data(true) -- A live creature must never show fictional sample data.
    local c = id and observed.creatures[tostring(id)]
    if not c or c.skins <= 0 or tooltip.tslSkinningGUID == guid then return end
    tooltip.tslSkinningGUID = guid
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine("|T" .. self.icon .. ":14|t " .. self.title,
        L(M.db.settings.scope == "character" and "This character" or "All characters"), 0.85, 0.73, 0.45, 0.65, 0.64, 0.58)
    local average = string.format("%.2f", c.units / c.skins)
    if self.locale == "deDE" then average = average:gsub("%.", ",") end
    tooltip:AddLine(self.Fmt("%s · average %s materials/skin", self.N(c.skins, "skin"), average), 0.82, 0.82, 0.75)
    tooltip:AddDoubleLine(L("Observed drops"), L("Total · observed rate"), 0.85, 0.73, 0.45, 0.65, 0.64, 0.58)
    local drops = {}
    for itemID, drop in pairs(c.items) do if drop.count > 0 then drops[#drops + 1] = itemID end end
    table.sort(drops, function(a, b)
        if c.items[a].count ~= c.items[b].count then return c.items[a].count > c.items[b].count end
        return a < b
    end)
    for i = 1, math.min(3, #drops) do
        local itemID = drops[i]
        local item, drop = observed.items[itemID], c.items[itemID]
        local name = item and self:ItemLabel(item) or (L("Material") .. " " .. itemID)
        local icon = item and item.icon or self.icon
        local rate = drop.drops and string.format("%.0f%%", drop.drops / c.skins * 100) or "--"
        tooltip:AddDoubleLine("|T" .. icon .. ":14|t " .. name, drop.count .. "×" .. self.Sep(true) .. rate, 0.93, 0.91, 0.84, 0.93, 0.91, 0.84)
    end
    if #drops > 3 then tooltip:AddLine(self.Fmt("%d more materials · /tsl for details", #drops - 3), 0.65, 0.64, 0.58) end
    if c.skins < 10 then tooltip:AddLine(L("Small sample · observed rates may vary."), 0.65, 0.64, 0.58, true) end
    local personal = M.db.characters[M.character].creatures[c.key]
    local skins = personal and personal.skins or 0
    local _, _, target = self.Rank(skins)
    tooltip:AddDoubleLine(L("Your species mastery"), skins >= 100 and L("Master") or (skins .. "/" .. target .. self.Sep() .. L(self.Rank(target))),
        0.85, 0.73, 0.45, 0.82, 0.82, 0.75)
    local goal, progress, other = M:GoalProgress(true)
    if goal and not other and c.items[goal.itemID] then
        tooltip:AddLine(L("Collection goal") .. ": " .. progress .. "/" .. goal.target .. " " .. goal.name, 0.49, 0.76, 0.60, true)
    end
    local note = M.db.notes[c.key]
    if note and note ~= "" then tooltip:AddLine(L("Field note") .. ": " .. note, 0.85, 0.87, 0.8, true) end
end

function S:HookTooltip()
    if not GameTooltip or not GameTooltip.HookScript or self.tooltipHookType == "modern" then return end
    if not self.tooltipClearHooked then
        GameTooltip:HookScript("OnTooltipCleared", function(tooltip) tooltip.tslSkinningGUID = nil end)
        self.tooltipClearHooked = true
    end
    local function add(tooltip, data) S:CreatureTooltip(tooltip, data) end
    -- Forever can expose the modern tooltip pipeline despite its Classic flavor.
    if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, add)
        self.tooltipHookType = "modern"
    elseif self.tooltipHookType ~= "legacy" then
        local ok = pcall(GameTooltip.HookScript, GameTooltip, "OnTooltipSetUnit", add)
        if ok then self.tooltipHookType = "legacy" end
    end
end

function S:Command(input)
    local command = (input or ""):match("^%s*(%S*)"):lower()
    if command == "here" or command == "atlas" then
        self.UI.atlasMap = C_Map and C_Map.GetBestMapForUnit("player")
        self.Maps:SetFilter(nil, nil); self.Maps:Open(self.UI.atlasMap)
    elseif command == "materials" then self.UI:Open("materials")
    elseif command == "session" then self.UI:Open("session")
    elseif command == "config" or command == "settings" then self.UI:Open("settings")
    elseif command == "demo" then self:ToggleDemo(); self.UI:Open(); self.HUD:Refresh(); self.Maps:Dirty()
    elseif command == "tracker" then self.Model.db.settings.hud = not self.Model.db.settings.hud; self.HUD:Refresh()
    elseif command == "research" then self.UI:Open("research")
    elseif command == "export" then self.UI:Export()
    elseif command == "new" then self.Model:NewSession(); self.UI:Open("session")
    elseif command == "help" then
        self:Welcome(true)
    elseif command == "ru" or command == "russian" then
        self.Model.db.settings.language = "ruRU"
        self:Print("Язык переключен на русский.")
        if self.UI then self.UI:Refresh() end
        if self.HUD then self.HUD:Refresh() end
    elseif command == "en" or command == "english" then
        self.Model.db.settings.language = "enUS"
        self:Print("Language set to English.")
        if self.UI then self.UI:Refresh() end
        if self.HUD then self.HUD:Refresh() end
    elseif command == "de" or command == "german" then
        self.Model.db.settings.language = "deDE"
        self:Print("Sprache auf Deutsch eingestellt.")
        if self.UI then self.UI:Refresh() end
        if self.HUD then self.HUD:Refresh() end
    else self.UI:Toggle() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= addonName then if S.Model.db then S.Maps:Init() end; return end
        S.Model:Init()
        S:CreateMinimap(); S:HookTooltip(); S.Maps:Init(); S.HUD:Refresh()
        SLASH_SKINNINGLOGSOL1 = "/slsol"
        SLASH_SKINNINGLOGSOL2 = "/skinningsol"
        SLASH_SKINNINGLOGSOL3 = "/skinninglog"
        SLASH_SKINNINGLOGSOL4 = "/tsl"
        SlashCmdList.SKINNINGLOGSOL = function(message) S:Command(message) end
        for _, e in ipairs({ "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_SUCCEEDED",
            "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED", "LOOT_READY", "LOOT_OPENED", "LOOT_SLOT_CLEARED",
            "LOOT_SLOT_CHANGED", "LOOT_CLOSED", "PLAYER_LOGOUT", "DISPLAY_SIZE_CHANGED", "PLAYER_LOGIN",
            "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "SKILL_LINES_CHANGED" }) do
            if events.RegisterUnitEvent and e:find("^UNIT_SPELLCAST_") then events:RegisterUnitEvent(e, "player")
            else events:RegisterEvent(e) end
        end
        S.Maps:StartMinimap()
    elseif event == "PLAYER_LOGOUT" then S.Model:ArchiveSession()
    elseif event == "DISPLAY_SIZE_CHANGED" then S.UI:Scale()
    elseif event == "PLAYER_LOGIN" then
        S.Maps:Init(); S.HUD:Refresh(); C_Timer.After(1, function() S:Welcome(false) end)
    elseif event == "PLAYER_REGEN_ENABLED" then
        if S.welcomePending then S.welcomePending = false; S:Welcome(false) end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "SKILL_LINES_CHANGED" then S.HUD:Refresh()
    else S.Tracker:Event(event, ...) end
end)
