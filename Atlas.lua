local _, S = ...
local U, M, L = S.UI, S.Model, S.L
S.Maps = { mini = {}, dirty = true }
local A = S.Maps
local template = "SkinningLogSolPinTemplate"
local pinLevel = "PIN_FRAME_LEVEL_SOL_SKINNING"

function A:SetFilter(kind, value)
    self.filterKind, self.filterValue = kind, value
    self:Dirty()
end

function A:FilterLabel()
    local data = M:Data()
    local prefix = S.demo and "[" .. L("Sample journal") .. "] " or ""
    if self.filterKind == "creature" and data.creatures[self.filterValue] then return prefix .. data.creatures[self.filterValue].name end
    if self.filterKind == "item" and data.items[self.filterValue] then return prefix .. data.items[self.filterValue].name end
    return prefix .. L("All creatures")
end

function A:Points(mapID, zoom)
    local data, cells = M:Data(), {}
    local step = 0.036 / math.max(1, zoom or 1)
    for zoneID, zone in pairs(data.zones) do
        local rect
        if zoneID ~= mapID and C_Map.GetMapRectOnMap and zone.mapID then
            local x1, x2, y1, y2 = C_Map.GetMapRectOnMap(zoneID, mapID)
            if x1 and x2 and x2 > x1 and y2 > y1 then rect = { x1, x2, y1, y2 } end
        end
        if zoneID == mapID or rect then
            for _, spot in pairs(zone.spots) do
                local skins, units, species, items = spot.skins, spot.units, spot.creatures, spot.items
                local match = true
                if self.filterKind == "creature" then
                    local sc = spot.creatures[self.filterValue]
                    match = sc ~= nil
                    if sc then skins, units, species, items = sc.skins, sc.units, { [self.filterValue] = sc }, sc.items or {} end
                elseif self.filterKind == "item" then
                    match = (spot.items[self.filterValue] or 0) > 0
                    units, items = spot.items[self.filterValue] or 0, { [self.filterValue] = spot.items[self.filterValue] or 0 }
                end
                if match then
                    local x, y = spot.x, spot.y
                    if rect then x = rect[1] + x * (rect[2] - rect[1]); y = rect[3] + y * (rect[4] - rect[3]) end
                    if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                        local bucket = math.floor(x / step) .. ":" .. math.floor(y / step)
                        local point = cells[bucket]
                        if not point then
                            local info = C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
                            point = { x = 0, y = 0, weight = 0, skins = 0, units = 0, creatures = {}, items = {}, mapID = mapID,
                                zone = rect and (info and info.name or L("Hunting grounds")) or zone.name, last = 0 }
                            cells[bucket] = point
                        end
                        local weight = math.max(1, skins)
                        point.x = point.x + x * weight; point.y = point.y + y * weight; point.weight = point.weight + weight
                        point.skins = point.skins + skins; point.units = point.units + units; point.last = math.max(point.last, spot.last or 0)
                        for key, sc in pairs(species) do point.creatures[key] = (point.creatures[key] or 0) + sc.skins end
                        for id, count in pairs(items) do point.items[id] = (point.items[id] or 0) + count end
                    end
                end
            end
        end
    end
    local points = {}
    for _, point in pairs(cells) do
        point.x, point.y = point.x / point.weight, point.y / point.weight
        local best, qty
        for id, count in pairs(point.items) do if not qty or count > qty or (qty == count and id < best) then best, qty = id, count end end
        point.icon = best and data.items[best] and data.items[best].icon or S.icon
        points[#points + 1] = point
    end
    table.sort(points, function(a, b) if a.units ~= b.units then return a.units > b.units end if a.x ~= b.x then return a.x < b.x end return a.y < b.y end)
    return points
end

function A:Tooltip(pin, point)
    local data = M:Data()
    GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    GameTooltip:SetText(string.format("%s  %.1f, %.1f", point.zone, point.x * 100, point.y * 100), 0.91, 0.76, 0.43)
    if S.demo then GameTooltip:AddLine(L("Fictional sample data"), 0.9, 0.7, 0.3) end
    GameTooltip:AddLine(S.Fmt("%d skinned · %d materials", point.skins, point.units), 0.9, 0.91, 0.83)
    local species = {}; for key, count in pairs(point.creatures) do species[#species + 1] = { key, count } end
    table.sort(species, function(a, b) return a[2] > b[2] end)
    for i = 1, math.min(3, #species) do
        local c = data.creatures[species[i][1]]
        if c then GameTooltip:AddLine(c.name .. "  ×" .. species[i][2], 0.78, 0.83, 0.73) end
    end
    local items = {}; for id, count in pairs(point.items) do items[#items + 1] = { id, count } end
    table.sort(items, function(a, b) return a[2] > b[2] end)
    for i = 1, math.min(3, #items) do
        local item = data.items[items[i][1]]
        if item then GameTooltip:AddLine("|T" .. (item.icon or S.icon) .. ":14|t " .. item.name .. "  ×" .. items[i][2], 0.88, 0.81, 0.61) end
    end
    if point.last > 0 then GameTooltip:AddLine(S.Fmt("Last visit: %s", date("%d.%m. %H:%M", point.last)), 0.6, 0.63, 0.58) end
    GameTooltip:AddLine(L("Click to inspect") .. S.Sep() .. L("Right click for a waypoint"), 0.8, 0.73, 0.48)
    GameTooltip:AddLine(L("Map pins mark where you stood while skinning; they are not verified spawns."), 0.6, 0.64, 0.59, true)
    GameTooltip:Show()
end

function A:Waypoint(point)
    if TomTom and TomTom.AddWaypoint then
        TomTom:AddWaypoint(point.mapID, point.x, point.y, { title = S.title .. ": " .. point.zone, persistent = false, minimap = true, world = true })
    elseif C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(point.mapID, point.x, point.y))
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
    else S:Print(string.format("%s: %.1f, %.1f" .. S.Sep() .. "TomTom", point.zone, point.x * 100, point.y * 100)) end
end

A.pinMethods = {
    OnLoad = function(pin)
        pin:SetIgnoreGlobalPinScale(true); pin:SetScalingLimits(1, 1, 1); pin:UseFrameLevelType(pinLevel)
        pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        -- Keep artwork in its own child above the canvas detail frames. Reset
        -- visibility on each acquisition because native map pins are pooled.
        pin.art = CreateFrame("Frame", nil, pin); pin.art:SetAllPoints()
        pin.rim = pin.art:CreateTexture(nil, "BACKGROUND"); pin.rim:SetAllPoints(); pin.rim:SetColorTexture(0.86, 0.63, 0.20, 1)
        pin.icon = pin.art:CreateTexture(nil, "OVERLAY"); pin.icon:SetPoint("TOPLEFT", 2, -2); pin.icon:SetSize(19, 19); pin.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end,
    OnAcquired = function(pin, point)
        pin.point = point
        if pin.icon:SetTexture(point.icon or S.icon) == false then pin.icon:SetTexture(S.icon) end
        pin:SetAlpha(1); pin:SetPosition(point.x, point.y); pin:ApplyCurrentScale()
        pin.art:SetFrameLevel(pin:GetFrameLevel() + 1); pin.art:SetAlpha(1); pin.art:Show(); pin.icon:Show(); pin.rim:Show()
    end,
    OnCanvasScaleChanged = function(pin)
        pin:ApplyCurrentScale(); pin.art:SetFrameLevel(pin:GetFrameLevel() + 1); pin:SetAlpha(1)
    end,
    OnReleased = function(pin) pin.point = nil end,
    OnClick = function(pin, button)
        if button == "RightButton" then A:Waypoint(pin.point) else U:LocationCard(pin.point) end
    end,
    OnMouseEnter = function(pin) A:Tooltip(pin, pin.point) end,
    OnMouseLeave = function() GameTooltip:Hide() end,
}

-- The bare XML template can load before Blizzard's map addon. Mix in the native
-- pin API only when the map instantiates it, after Blizzard_MapCanvas is ready.
function SkinningLogSolPin_OnLoad(pin)
    Mixin(pin, MapCanvasPinMixin, A.pinMethods)
end

function A:Init()
    if self.provider then return true end
    if not WorldMapFrame or not WorldMapFrame.AddDataProvider or not MapCanvasDataProviderMixin then return false end
    local levels = WorldMapFrame.GetPinFrameLevelsManager and WorldMapFrame:GetPinFrameLevelsManager()
    if levels and levels.AddFrameLevel then levels:AddFrameLevel(pinLevel) end
    local provider = CreateFromMixins(MapCanvasDataProviderMixin)
    function provider:RemoveAllData() self:GetMap():RemoveAllPinsByTemplate(template) end
    function provider:RefreshAllData()
        self:RemoveAllData()
        if not M.db or not M.db.settings.worldPins then return end
        local map = self:GetMap()
        if not map:IsShown() then return end
        local points = A:Points(map:GetMapID(), map:GetCanvasScale())
        for i = 1, math.min(120, #points) do map:AcquirePin(template, points[i]) end
        if A.mapFilter then A.mapFilter.label:SetText(A:FilterLabel()) end
        if A.mapToggle then A.mapToggle.label:SetText(L("Skins") .. ": " .. L(M.db.settings.worldPins and "On" or "Off")) end
    end
    function provider:OnCanvasScaleChanged()
        -- Recluster after zoom settles, without re-acquiring pins every frame.
        if A.zoomQueued then return end
        A.zoomQueued = true
        C_Timer.After(0.3, function() A.zoomQueued = false; if WorldMapFrame:IsShown() then self:RefreshAllData() end end)
    end
    self.provider = provider; WorldMapFrame:AddDataProvider(provider)
    U:Static(function()
        local parent = WorldMapFrame.ScrollContainer or WorldMapFrame
        local controls = U:Panel(parent, 0, 0, 278, 35)
        controls:ClearAllPoints(); controls:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 9, 9); controls:SetFrameLevel(parent:GetFrameLevel() + 20)
        self.mapToggle = U:Button(controls, L("Skins") .. ": " .. L(M.db.settings.worldPins and "On" or "Off"), 5, 5, 72, 25, function()
            M.db.settings.worldPins = not M.db.settings.worldPins; self:Dirty()
        end)
        self.mapFilter = U:Button(controls, self:FilterLabel(), 83, 5, 189, 25, function() self:SetFilter(nil, nil) end)
        U:Tooltip(self.mapFilter, "Clear map filter", { "Your recorded positions" })
    end)
    provider:RefreshAllData()
    return true
end

function A:Dirty()
    self.dirty = true
    local data = M:Data()
    if (self.filterKind == "creature" and not data.creatures[self.filterValue]) or
        (self.filterKind == "item" and not data.items[self.filterValue]) then self.filterKind, self.filterValue = nil, nil end
    self:StartMinimap()
    if self.provider and WorldMapFrame and WorldMapFrame:IsShown() then self.provider:RefreshAllData() end
    if self.mapToggle then self.mapToggle.label:SetText(L("Skins") .. ": " .. L(M.db.settings.worldPins and "On" or "Off")) end
    if self.mapFilter then self.mapFilter.label:SetText(self:FilterLabel()) end
end

function A:StartMinimap()
    if not M.db.settings.miniPins then
        for _, pin in ipairs(self.mini) do pin:Hide(); pin.point = nil end
        self.miniPoints, self.miniMapID = nil, nil
        return
    end
    if self.miniPolling then return end
    self.miniPolling = true
    local function tick()
        if not M.db.settings.miniPins then
            self.miniPolling = false
            for _, pin in ipairs(self.mini) do pin:Hide(); pin.point = nil end
            self.miniPoints, self.miniMapID = nil, nil
            return
        end
        self:UpdateMinimap(); C_Timer.After(1, tick)
    end
    tick()
end

function A:Open(mapID)
    if not mapID or mapID == 0 then
        local best = -1
        for id, zone in pairs(M:Data().zones) do
            local units = 0; for _, point in ipairs(self:Points(id)) do units = units + point.units end
            if zone.mapID and units > best then best, mapID = units, id end
        end
        mapID = mapID or (C_Map and C_Map.GetBestMapForUnit("player"))
    end
    if U.frame then U.frame:Hide() end
    if not WorldMapFrame and C_AddOns and C_AddOns.LoadAddOn then C_AddOns.LoadAddOn("Blizzard_WorldMap") end
    if ToggleWorldMap and (not WorldMapFrame or not WorldMapFrame:IsShown()) then ToggleWorldMap() end
    if WorldMapFrame then
        self:Init(); if mapID then WorldMapFrame:SetMapID(mapID) end
        if self.provider then self.provider:RefreshAllData() end
    else S:Print(L("Open world map") .. S.Sep() .. "/tsl here") end
end

function A:UpdateMinimap()
    for _, pin in ipairs(self.mini) do pin:Hide() end
    if not M.db.settings.miniPins or not Minimap:IsShown() then return end
    if not CreateVector2D or not C_Map.GetWorldPosFromMapPos then return end
    local loc = S.Tracker:Location()
    if not loc.x or loc.x > 0.999 or loc.y > 0.999 then return end
    local _, center = C_Map.GetWorldPosFromMapPos(loc.mapID, CreateVector2D(loc.x, loc.y))
    local _, east = C_Map.GetWorldPosFromMapPos(loc.mapID, CreateVector2D(loc.x + 0.001, loc.y))
    local _, south = C_Map.GetWorldPosFromMapPos(loc.mapID, CreateVector2D(loc.x, loc.y + 0.001))
    if not center or not east or not south then return end
    local cx, cy = center:GetXY(); local ex, ey = east:GetXY(); local sx, sy = south:GetXY()
    local width = math.sqrt((ex - cx)^2 + (ey - cy)^2) * 1000
    local height = math.sqrt((sx - cx)^2 + (sy - cy)^2) * 1000
    local ranges = IsIndoors and IsIndoors() and { 150, 120, 90, 60, 40, 25 } or { 233.333, 200, 166.667, 133.333, 100, 66.667 }
    local radius = C_Minimap and C_Minimap.GetViewRadius and C_Minimap.GetViewRadius() or ranges[math.min(6, (Minimap:GetZoom() or 0) + 1)]
    if not radius or radius <= 0 then return end
    local facing = GetCVar and GetCVar("rotateMinimap") == "1" and GetPlayerFacing and (GetPlayerFacing() or 0) or 0
    -- Recorded observations change only on Dirty(). Movement updates reuse one
    -- zone's clusters instead of rebuilding every saved observation each tick.
    if self.dirty or self.miniMapID ~= loc.mapID or not self.miniPoints then
        self.miniPoints, self.miniMapID = self:Points(loc.mapID, 3), loc.mapID
        self.dirty = false
    end
    local points, shown = self.miniPoints, 0
    for _, point in ipairs(points) do
        local dx, dy = (point.x - loc.x) * width, (loc.y - point.y) * height
        if dx * dx + dy * dy < radius * radius and shown < 30 then
            shown = shown + 1
            local pin = self.mini[shown]
            if not pin then
                pin = CreateFrame("Button", nil, Minimap); pin:SetSize(16, 16); pin:SetFrameLevel(Minimap:GetFrameLevel() + 5)
                pin.icon = pin:CreateTexture(nil, "ARTWORK"); pin.icon:SetAllPoints(); pin.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                pin:SetScript("OnEnter", function(self) A:Tooltip(self, self.point) end); pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
                pin:SetScript("OnClick", function(self, button) if button == "RightButton" then A:Waypoint(self.point) else U:LocationCard(self.point) end end)
                self.mini[shown] = pin
            end
            pin.point = point; pin.icon:SetTexture(point.icon or S.icon); pin:ClearAllPoints()
            pin:SetPoint("CENTER", Minimap, "CENTER", (dx * math.cos(facing) + dy * math.sin(facing)) / radius * (Minimap:GetWidth() / 2 - 8),
                (-dx * math.sin(facing) + dy * math.cos(facing)) / radius * (Minimap:GetHeight() / 2 - 8)); pin:Show()
        end
    end
end

function U:LocationCard(point)
    self:Static(function()
        local data = M:Data()
        if not self.location then
            local f = self:Panel(UIParent, 0, 0, 465, 410)
            f:ClearAllPoints(); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true)
            f.title = self:OneLine(f, "", 18, 18, 18, self.c.gold, 415)
            f.meta = self:Text(f, "", 18, 50, 12, self.c.muted, 420)
            f.rows = {}; for i = 1, 4 do
                local row = self:Button(f, "", 18, 91 + (i - 1) * 40, 429, 34, nil); f.rows[i] = row
            end
            f.items = self:Text(f, "", 18, 270, 12, self.c.text, 429)
            self:Button(f, "Set waypoint", 18, 365, 207, 29, function() A:Waypoint(f.point) end)
            self:Button(f, "Close", 240, 365, 207, 29, function() f:Hide() end)
            _G.SkinningLogSolLocation = f; table.insert(UISpecialFrames, "SkinningLogSolLocation"); self.location = f
        end
        local f = self.location; f.point = point
        f.title:SetText(point.zone .. string.format("  %.1f, %.1f", point.x * 100, point.y * 100))
        f.meta:SetText(S.Fmt("%d skinned · %d materials", point.skins, point.units))
        local creatures = {}; for key, count in pairs(point.creatures) do creatures[#creatures + 1] = { key, count } end
        table.sort(creatures, function(a, b) return a[2] > b[2] end)
        for i, row in ipairs(f.rows) do
            local c = creatures[i]; row:SetShown(c ~= nil)
            if c then
                row.label:SetText(data.creatures[c[1]].name .. "  ×" .. c[2])
                row:SetScript("OnClick", function() U:CreatureSheet(c[1]); f:Hide() end)
            end
        end
        local items = {}; for id, count in pairs(point.items) do if data.items[id] then items[#items + 1] = data.items[id].name .. "  ×" .. count end end
        table.sort(items); local lines = {}; for i = 1, math.min(3, #items) do lines[i] = items[i] end
        f.items:SetText(table.concat(lines, "\n")); f:SetScale(math.min(1, (UIParent:GetHeight() - 30) / 410)); f:Show()
    end)
end

function U:Atlas()
    local p, data = self.content, M:Data()
    self.footer:SetText(L("Map pins mark where you stood while skinning; they are not verified spawns."))
    local zones, labels = {}, {}
    for id, z in pairs(data.zones) do if z.mapID then zones[#zones + 1] = { id = id, zone = z } end end
    table.sort(zones, function(a, b) return a.zone.name < b.zone.name end)
    for _, z in ipairs(zones) do labels[#labels + 1] = { z.id, z.zone.name } end
    if #zones == 0 then self:Empty(p, "Hunting grounds", "No recorded positions in this area yet.", 70); return end
    local selected = data.zones[self.atlasMap] and self.atlasMap or zones[1].id; self.atlasMap = selected
    local zone = data.zones[selected]
    self:Dropdown(p, zone.name, 0, 0, 280, labels, selected, function(id) self.atlasMap = id; self.page = 1; self:Refresh() end)
    self:Button(p, A:FilterLabel(), 294, 0, 382, 28, function() A:SetFilter(nil, nil); self:Refresh() end, A.filterKind ~= nil)
    self:Button(p, "Open world map", 690, 0, 202, 28, function() A:Open(selected) end)
    local points = A:Points(selected, 1)
    self.page = math.min(self.page, math.max(1, math.ceil(#points / 6)))
    self:Text(p, "Your recorded positions", 10, 48, 11, self.c.gold)
    for i = 1, 6 do
        local point = points[(self.page - 1) * 6 + i]
        if point then
            local row = self:Button(p, "", 0, 74 + (i - 1) * 51, 548, 45, function() self:LocationCard(point) end)
            self:Icon(row, point.icon, 8, 8, 29)
            local top, count
            for key, n in pairs(point.creatures) do if not count or n > count then top, count = key, n end end
            self:OneLine(row, top and data.creatures[top].name or zone.name, 49, 7, 12, self.c.text, 350)
            self:Text(row, string.format("%.1f, %.1f", point.x * 100, point.y * 100) .. S.Sep() .. S.N(point.skins, "skin"), 49, 27, 10, self.c.muted)
            self:OneLine(row, tostring(point.units), 476, 12, 18, self.c.gold, 60)
            self:Tooltip(row, "Your recorded positions", { S.Fmt("%d skinned · %d materials", point.skins, point.units), "Click to inspect" })
        end
    end
    local card = self:Panel(p, 567, 49, 325, 367)
    self:Icon(card, "Interface\\Icons\\INV_Misc_Map_01", 131, 23, 64)
    self:Text(card, zone.name, 17, 108, 21, self.c.gold, 291)
    self:Text(card, S.Fmt("%d species discovered", S.Count(zone.creatures)), 17, 156, 13, self.c.text, 290)
    self:Text(card, S.Fmt("%d creatures skinned", zone.skins), 17, 184, 13, self.c.text, 290)
    self:Text(card, S.Fmt("%d materials collected", zone.units), 17, 212, 13, self.c.text, 290)
    self:Text(card, "Your recorded positions", 17, 258, 11, self.c.muted, 290)
    self:Button(card, "Open world map", 16, 299, 293, 39, function() A:Open(selected) end)
    self:Pagination(p, #points, 6, 431)
end
