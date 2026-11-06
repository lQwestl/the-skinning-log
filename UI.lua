local _, S = ...
local L, M = S.L, S.Model
local unpack = unpack or table.unpack
local white = "Interface\\Buttons\\WHITE8X8"
S.UI = { tab = "guide", page = 1, sort = "yield", filter = "all", search = "", widgets = {}, pool = {}, nav = {} }
local U = S.UI
U.c = { bg = { 0.09, 0.065, 0.045, 1 }, panel = { 0.085, 0.06, 0.04, 1 },
    raised = { 0.24, 0.18, 0.075, 1 }, line = { 0.48, 0.35, 0.19, 1 },
    gold = { 1, 0.82, 0, 1 }, text = { 1, 0.96, 0.88, 1 }, muted = { 0.70, 0.66, 0.56, 1 },
    green = { 0.49, 0.76, 0.60, 1 }, blue = { 0.43, 0.66, 0.82, 1 } }

function S:ItemLabel(item)
    local quality = item.quality
    local getInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
    if quality == nil and getInfo and item.id then local _, _, q = getInfo(item.id); quality = q end
    local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality or -1]
    return color and color.hex and (color.hex .. item.name .. "|r") or item.name
end

function U:Static(fn)
    local old = self.collect; self.collect = false
    local ok, result = pcall(fn)
    self.collect = old
    if not ok then error(result, 0) end
    return result
end

function U:Acquire(kind, parent, make)
    if not self.collect then return make() end
    local pool = self.pool[kind]
    if not pool then pool = { used = 0 }; self.pool[kind] = pool end
    pool.used = pool.used + 1
    local w = pool[pool.used]
    if not w then w = make(); pool[pool.used] = w end
    w:SetParent(parent); w:ClearAllPoints(); w:Show(); w:SetAlpha(1)
    self.widgets[#self.widgets + 1] = w
    return w
end

-- Backdrop images may contain transparency. A separate opaque underlay keeps
-- terrain and nameplates out of every journal, tracker and popup surface.
function U:Opaque(frame, color)
    if not frame.solUnderlay then frame.solUnderlay = frame:CreateTexture(nil, "BACKGROUND", nil, -8) end
    local t = frame.solUnderlay
    t:ClearAllPoints(); t:SetPoint("TOPLEFT", 3, -3); t:SetPoint("BOTTOMRIGHT", -3, 3)
    t:SetColorTexture(unpack(color or self.c.panel)); t:Show()
end

function U:Panel(parent, x, y, w, h, color)
    local f = self:Acquire("panel", parent, function() return CreateFrame("Frame", nil, parent, "InsetFrameTemplate,BackdropTemplate") end)
    f:SetPoint("TOPLEFT", x, -y); f:SetSize(w, h)
    f:SetFrameLevel(parent:GetFrameLevel() + 1)
    if f.Bg then f.Bg:Hide() end
    if f.NineSlice then f.NineSlice:SetFrameLevel(f:GetFrameLevel()) end
    self:Opaque(f, color)
    f:SetBackdrop({ bgFile = "Interface\\FrameGeneral\\UI-Background-Marble", tile = true, tileSize = 128,
        insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    f:SetBackdropColor(0.88, 0.80, 0.67, 1)
    return f
end

function U:Text(parent, text, x, y, size, color, width)
    local f = self:Acquire("text", parent, function() return parent:CreateFontString(nil, "OVERLAY") end)
    f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size or 12, "")
    f:SetShadowColor(0, 0, 0, 1); f:SetShadowOffset(1, -1)
    f:SetPoint("TOPLEFT", x, -y); f:SetTextColor(unpack(color or self.c.text))
    f:SetJustifyH("LEFT"); f:SetJustifyV("TOP"); f:SetWordWrap(true)
    f:SetWidth(width or 0); f:SetHeight(0); f:SetMaxLines(0); f:SetText(L(text or ""))
    return f
end

function U:OneLine(parent, text, x, y, size, color, width)
    local f = self:Text(parent, text, x, y, size, color, width)
    f:SetMaxLines(1); f:SetWordWrap(false)
    return f
end

function U:Line(parent, x, y, w, color)
    local t = self:Acquire("rule", parent, function() return parent:CreateTexture(nil, "ARTWORK") end)
    t:SetPoint("TOPLEFT", x, -y); t:SetSize(w, 1); t:SetColorTexture(unpack(color or self.c.line))
    return t
end

function U:Section(parent, label, x, y, width)
    -- The 170px category art occupies part of a 256x32 texture. Keep its
    -- end caps at native width; stretching them moves the border over the text.
    local edges = { { 0, 12, 0, 12 }, { 12, width - 24, 12, 158 }, { width - 12, 12, 158, 170 } }
    for _, edge in ipairs(edges) do
        local t = self:Acquire("section", parent, function() return parent:CreateTexture(nil, "ARTWORK", nil, -1) end)
        t:SetPoint("TOPLEFT", x + edge[1], -y); t:SetSize(edge[2], 25)
        t:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Background")
        t:SetVertexColor(1, 0.92, 0.78, 1)
        t:SetTexCoord(edge[3] / 256, edge[4] / 256, 0, 26 / 32)
    end
    local text = self:OneLine(parent, label, x + 16, y + 4, 12, self.c.gold, width - 32)
    text:SetHeight(18); text:SetJustifyV("MIDDLE")
    return text
end

function U:PaintButton(b, selected)
    b.selected = selected
    if b.solStyle == "sidebar" then
        b.SelectedGlow:SetShown(selected and true or false)
    elseif b.solStyle == "tab" then
        for _, key in ipairs({ "Left", "Middle", "Right" }) do
            if b[key] then b[key]:SetShown(not selected) end
            if b[key .. "Disabled"] then b[key .. "Disabled"]:SetShown(selected and true or false) end
        end
    elseif b.solStyle == "row" then
        b:SetBackdropColor(0.82, 0.73, 0.59, 1); b:SetBackdropBorderColor(unpack(selected and self.c.gold or self.c.line))
        b.selection:SetShown(selected and true or false)
    end
    if b.label then b.label:SetTextColor(unpack(selected and self.c.gold or (b.solStyle == "row" and self.c.text or self.c.gold))) end
end

function U:TabArt(button, width, height)
    -- Build our own regions: Classic client builds expose different fields and
    -- initialization scripts on TabButtonTemplate. Only the native artwork is
    -- shared, so no Blizzard tab constructor can interrupt journal creation.
    local pieces = { { "Left", 0, 0.25, 16 }, { "Middle", 0.25, 0.75, math.max(1, width - 32) }, { "Right", 0.75, 1, 16 } }
    for _, piece in ipairs(pieces) do
        for _, suffix in ipairs({ "", "Disabled" }) do
            local key = piece[1] .. suffix
            local texture = button[key]
            if not texture then texture = button:CreateTexture(nil, "BACKGROUND"); button[key] = texture end
            texture:ClearAllPoints(); texture:SetSize(piece[4], height)
            if piece[1] == "Left" then texture:SetPoint("TOPLEFT")
            elseif piece[1] == "Right" then texture:SetPoint("TOPRIGHT")
            else texture:SetPoint("TOPLEFT", 16, 0) end
            texture:SetTexture("Interface\\HelpFrame\\HelpFrameTab-" .. (suffix == "" and "Inactive" or "Active"))
            texture:SetTexCoord(piece[2], piece[3], 0, 1)
        end
    end
    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
end

function U:AtlasInfo(name)
    return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name)
end

function U:ApplyAtlas(texture, name)
    local info = self:AtlasInfo(name)
    if not info or not texture.SetAtlas then return nil end
    texture:SetAtlas(name, false)
    return info
end

function U:SidebarAvailable()
    for _, name in ipairs({ "Legacy-Tree-Frame-Card", "Legacy-Tree-Frame-Card-Ring", "Legacy-Tree-Frame-Card-Glow",
        "Legacy-Tree-Frame-divider-Vertical", "Legacy-Tree-Frame-background" }) do
        if not self:AtlasInfo(name) then return false end
    end
    return true
end

function U:SidebarButton(parent, name, label, icon, y)
    -- Exact LegacyTreeButton artwork and geometry, with our own click handlers.
    -- No Legacy UI template, event bus or talent-system dependency is loaded.
    local b = CreateFrame("Button", nil, parent)
    b:SetPoint("TOPLEFT", 0, -y); b:SetSize(142, 82); b:SetFrameLevel(parent:GetFrameLevel() + 2)
    b.solStyle, b.pageLabel = "sidebar", label
    b.Background = b:CreateTexture(nil, "BACKGROUND", nil, 0)
    b.Background:SetPoint("CENTER"); b.Background:SetSize(142, 93); self:ApplyAtlas(b.Background, "Legacy-Tree-Frame-Card")
    b.SelectedGlow = b:CreateTexture(nil, "BACKGROUND", nil, 1)
    local glow = self:ApplyAtlas(b.SelectedGlow, "Legacy-Tree-Frame-Card-Glow")
    b.SelectedGlow:SetSize(glow.width, glow.height)
    b.SelectedGlow:SetPoint("RIGHT", b.Background, "RIGHT", -10, 0); b.SelectedGlow:Hide()
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("CENTER"); b.icon:SetSize(67, 67); b.icon:SetTexture(icon)
    if b.CreateMaskTexture and b.icon.AddMaskTexture then
        b.mask = b:CreateMaskTexture()
        b.mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        b.mask:SetPoint("CENTER"); b.mask:SetSize(69, 69); b.icon:AddMaskTexture(b.mask)
    elseif SetPortraitToTexture then SetPortraitToTexture(b.icon, icon) end
    b.Ring = b:CreateTexture(nil, "OVERLAY", nil, -1)
    b.Ring:SetPoint("CENTER"); b.Ring:SetSize(70, 70); self:ApplyAtlas(b.Ring, "Legacy-Tree-Frame-Card-Ring")
    b.Highlight = b:CreateTexture(nil, "OVERLAY")
    b.Highlight:SetPoint("CENTER"); b.Highlight:SetSize(70, 70); self:ApplyAtlas(b.Highlight, "Legacy-Tree-Frame-Card-Ring")
    b.Highlight:SetBlendMode("ADD"); b.Highlight:SetAlpha(0.5); b.Highlight:Hide()
    b:SetScript("OnClick", function() self:SelectTab(name) end)
    b:SetScript("OnEnter", function()
        b.Highlight:Show(); GameTooltip:SetOwner(b, "ANCHOR_RIGHT"); GameTooltip:SetText(L(label), 1, 0.82, 0); GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() b.Highlight:Hide(); GameTooltip:Hide() end)
    b:SetScript("OnMouseDown", function() b.icon:SetVertexColor(0.7, 0.7, 0.7) end)
    b:SetScript("OnMouseUp", function() b.icon:SetVertexColor(1, 1, 1) end)
    return b
end

function U:Button(parent, text, x, y, w, h, callback, selected, style)
    style = style or (text == "" and "row" or "action")
    local template = style == "action" and "UIPanelButtonTemplate,BackdropTemplate" or "BackdropTemplate"
    local b = self:Acquire("button:" .. style, parent, function() return CreateFrame("Button", nil, parent, template) end)
    b:SetPoint("TOPLEFT", x, -y); b:SetSize(w, h or 28); b.selected = selected
    b.solStyle = style; b:SetFrameLevel(parent:GetFrameLevel() + 1)
    if b.Text then b.Text:Hide() end
    if style == "row" then
        self:Opaque(b)
        b:SetBackdrop({ bgFile = "Interface\\FrameGeneral\\UI-Background-Marble", tile = true, tileSize = 128,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 } })
        if not b.selection then
            b.selection = b:CreateTexture(nil, "BORDER")
            b.selection:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight"); b.selection:SetBlendMode("ADD")
        end
        b.selection:ClearAllPoints(); b.selection:SetPoint("TOPLEFT", 2, -2); b.selection:SetPoint("BOTTOMRIGHT", -2, 2)
        b.selection:SetVertexColor(0.9, 0.65, 0.18, 0.42)
        b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    elseif style == "tab" then
        self:TabArt(b, w, h or 28)
    end
    b.label = self:OneLine(b, text, 0, 0, 12, selected and self.c.gold or self.c.text, w - 12)
    b.label:ClearAllPoints(); b.label:SetPoint("CENTER", 0, style == "tab" and -4 or 0)
    b.label:SetHeight((h or 28) - 8); b.label:SetJustifyH("CENTER"); b.label:SetJustifyV("MIDDLE")
    self:PaintButton(b, selected)
    b:SetScript("OnClick", callback)
    b:SetScript("OnEnter", function(self) self.label:SetTextColor(1, 1, 1) end)
    b:SetScript("OnLeave", function(self) U:PaintButton(self, self.selected); GameTooltip:Hide() end)
    return b
end

function U:Icon(parent, texture, x, y, size)
    local f = self:Acquire("icon", parent, function() return parent:CreateTexture(nil, "ARTWORK") end)
    f:SetPoint("TOPLEFT", x, -y); f:SetSize(size or 30, size or 30)
    f:SetTexture(texture or S.icon); f:SetTexCoord(0.07, 0.93, 0.07, 0.93); f:SetVertexColor(1, 1, 1); f:SetDrawLayer("ARTWORK", 0)
    return f
end

function U:AssignCreature(model, creature, fallback, zoom)
    model.solFallback = fallback
    model:SetScript("OnModelLoaded", function(self)
        self.solLoaded = true
        if self.solFallback then self.solFallback:Hide() end
    end)
    if not creature.npcID then model:Hide(); fallback:Show(); return end
    model:Show()
    if model.solNPC ~= creature.npcID then
        model.solNPC, model.solLoaded = creature.npcID, false
        fallback:Show()
        local ok = pcall(model.SetCreature, model, creature.npcID)
        if not ok then model:Hide() end
    end
    fallback:SetShown(not model.solLoaded)
    pcall(model.SetPortraitZoom, model, zoom or 0.45); pcall(model.SetFacing, model, 0.35)
end

function U:SetBar(bar, percent)
    local fraction = math.max(0, math.min(1, percent or 0))
    bar.progress = fraction
    bar.fill:SetShown(fraction > 0)
    if bar.pattern then bar.pattern:SetShown(fraction > 0) end
    local width = math.max(0.01, (bar:GetWidth() - 4) * fraction)
    if bar.mask then bar.mask:SetWidth(width)
    else
        bar.fill:SetWidth(width)
        if bar.pattern then
            -- A client without masks still crops a settled still proportionally.
            bar.pattern:SetWidth(width)
            local uv = bar.patternUV
            bar.pattern:SetTexCoord(uv[1], uv[1] + (uv[2] - uv[1]) * fraction, uv[3], uv[4])
        end
    end
end

function U:Bar(parent, x, y, w, percent, color, height)
    local bar = self:Acquire("progressbar", parent, function()
        local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        f.background = f:CreateTexture(nil, "BACKGROUND")
        f.fill = f:CreateTexture(nil, "ARTWORK", nil, 1)
        -- A shaded base remains under translucent profession detail and also
        -- supplies a usable fill when that native artwork is unavailable.
        f.fill:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        f.rim = f:CreateTexture(nil, "OVERLAY")
        local native = self:ApplyAtlas(f.background, "Profession-ProgressBar-BG")
        native = self:ApplyAtlas(f.rim, "Profession-ProgressBar-frame") and native
        -- DefaultBlue is the client's smooth bevel, not the patterned leather
        -- shown by Leatherworking. Select that profession's actual art first.
        local fillAtlas = "Skillbar_Fill_Flipbook_Leatherworking"
        local art = self:AtlasInfo(fillAtlas)
        if not art then fillAtlas = "Skillbar_Fill_Flipbook_DefaultBlue"; art = self:AtlasInfo(fillAtlas) end
        if art and art.height >= 34 and f.fill.SetAtlas then
            f.pattern = f:CreateTexture(nil, "ARTWORK", nil, 2)
            self:ApplyAtlas(f.pattern, fillAtlas)
            -- Match the settled final frame of the native two-column flipbook,
            -- rather than its opening transition. No animation or idle updates.
            local left, right, top, bottom = art.leftTexCoord, art.rightTexCoord, art.topTexCoord, art.bottomTexCoord
            local rowHeight = (bottom - top) * 34 / art.height
            f.patternUV = { left + (right - left) / 2, right, bottom - rowHeight, bottom }
            f.pattern:SetTexCoord(unpack(f.patternUV))
            if f.pattern.SetDesaturated then f.pattern:SetDesaturated(true) end
            f.pattern:SetBlendMode("BLEND"); f.pattern:SetAlpha(0.85)
        end
        if not native then
            f.background:SetColorTexture(0.015, 0.01, 0.008, 1); f.rim:Hide()
            f:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8 })
            f:SetBackdropBorderColor(0.58, 0.43, 0.22, 1)
        end
        f.background:SetAllPoints(); f.rim:SetAllPoints()
        if f.CreateMaskTexture and f.fill.AddMaskTexture then
            f.mask = f:CreateMaskTexture()
            -- A solid rectangular mask reveals the fixed-size fill rather than
            -- stretching its artwork whenever progress changes.
            f.mask:SetTexture(white, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            f.mask:SetPoint("TOPLEFT", 2, -3); f.fill:AddMaskTexture(f.mask)
            if f.pattern then f.pattern:AddMaskTexture(f.mask) end
        end
        return f
    end)
    height = height or 20
    bar:SetPoint("TOPLEFT", x, -y); bar:SetSize(w, height); bar:SetFrameLevel(parent:GetFrameLevel() + 1)
    bar.fill:ClearAllPoints(); bar.fill:SetPoint("TOPLEFT", 2, -3); bar.fill:SetSize(w - 4, height - 6)
    bar.fill:SetVertexColor(unpack(color or self.c.gold))
    if bar.pattern then
        bar.pattern:ClearAllPoints(); bar.pattern:SetPoint("TOPLEFT", 2, -3)
        bar.pattern:SetSize(w - 4, height - 6); bar.pattern:SetVertexColor(unpack(color or self.c.gold))
    end
    if bar.mask then bar.mask:SetHeight(height - 6) end
    self:SetBar(bar, percent)
    return bar
end

function U:Tooltip(owner, title, lines)
    owner:EnableMouse(true)
    owner:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetText(L(title), 0.91, 0.76, 0.43)
        for _, line in ipairs(lines) do GameTooltip:AddLine(L(line), 0.85, 0.87, 0.79, true) end
        GameTooltip:Show()
    end)
    owner:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function U:Input(parent, x, y, w, placeholder, callback)
    local box = self:Acquire("input", parent, function() return CreateFrame("EditBox", nil, parent, "BackdropTemplate") end)
    box:SetPoint("TOPLEFT", x, -y); box:SetSize(w, 29)
    box:SetBackdrop({ bgFile = white, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 } })
    box:SetBackdropColor(0.025, 0.018, 0.012, 1); box:SetBackdropBorderColor(unpack(self.c.line))
    box:SetFont(STANDARD_TEXT_FONT, 12, ""); box:SetTextColor(unpack(self.c.text)); box:SetTextInsets(9, 9, 0, 0)
    box:SetAutoFocus(false); box:SetNumeric(false); box:SetMultiLine(false); box:SetMaxLetters(255)
    box.hint = self:OneLine(box, placeholder or "", 9, 8, 11, self.c.muted, w - 18)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnTextChanged", function(self, userInput)
        self.hint:SetShown(self:GetText() == "")
        if callback and userInput then callback(self:GetText()) end
    end)
    return box
end

function U:Menu(anchor, choices, current, callback, offset)
    self:Static(function()
        if not self.menu then
            local f = self:Panel(UIParent, 0, 0, 215, 30)
            f:SetFrameStrata("TOOLTIP"); f:EnableMouse(true); self.menu = f; f.rows = {}
            _G.SkinningLogSolMenu = f; table.insert(UISpecialFrames, "SkinningLogSolMenu")
        end
        local f = self.menu
        f:ClearAllPoints(); f:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -3)
        local visible = math.min(10, #choices)
        offset = math.min(math.max(0, offset or 0), math.max(0, #choices - visible))
        f:SetSize(215, visible * 29 + 12 + (#choices > visible and 28 or 0))
        for _, row in ipairs(f.rows) do row:Hide() end
        for i = 1, visible do
            local choice = choices[i + offset]
            local row = f.rows[i]
            if not row then row = self:Button(f, "", 6, 6 + (i - 1) * 29, 203, 27, nil); f.rows[i] = row end
            row.label:SetText((choice[1] == current and "|cffe8c26e" or "") .. L(choice[2]) .. "|r")
            row:SetScript("OnClick", function() f:Hide(); callback(choice[1]) end); row:Show()
        end
        if not f.previous then
            f.previous = self:Button(f, "^", 6, 0, 96, 23, nil)
            f.next = self:Button(f, "v", 111, 0, 98, 23, nil)
        end
        f.previous:ClearAllPoints(); f.previous:SetPoint("TOPLEFT", 6, -visible * 29 - 7)
        f.next:ClearAllPoints(); f.next:SetPoint("TOPLEFT", 111, -visible * 29 - 7)
        f.previous:SetShown(offset > 0); f.next:SetShown(offset + visible < #choices)
        f.previous:SetScript("OnClick", function() self:Menu(anchor, choices, current, callback, offset - visible) end)
        f.next:SetScript("OnClick", function() self:Menu(anchor, choices, current, callback, offset + visible) end)
        f:EnableMouseWheel(true)
        f:SetScript("OnMouseWheel", function(_, delta) self:Menu(anchor, choices, current, callback, offset - delta) end)
        f:Show()
    end)
end

function U:Dropdown(parent, label, x, y, w, choices, current, callback)
    local b
    b = self:Button(parent, L(label) .. "  v", x, y, w, 28, function() self:Menu(b, choices, current, callback) end, false, "row")
    return b
end

function U:SavePosition(frame, key)
    local point, _, relativePoint, x, y = frame:GetPoint(1)
    M.db.settings[key] = { point = point, relativePoint = relativePoint, x = x, y = y }
end

function U:RestorePosition(frame, key, point, x, y)
    local pos = M.db.settings[key]
    frame:ClearAllPoints()
    if pos and pos.point and pos.relativePoint then frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    else frame:SetPoint(point or "CENTER", UIParent, point or "CENTER", x or 0, y or 0) end
end

function U:DragHandle(handle, window, key)
    handle:EnableMouse(true); handle:RegisterForDrag("LeftButton")
    handle:SetScript("OnDragStart", function() window:StartMoving() end)
    handle:SetScript("OnDragStop", function() window:StopMovingOrSizing(); self:SavePosition(window, key) end)
end

function U:Build()
    if self.frame then return end
    -- Native frames cannot be discarded like Lua tables. Permit one recovery
    -- attempt, then stop allocating failed frame trees until the UI reloads.
    if (self.buildAttempts or 0) >= 2 then error(L("Journal creation failed twice. Use /reload before trying again."), 0) end
    self.buildAttempts = (self.buildAttempts or 0) + 1
    self:Static(function()
        local f = CreateFrame("Frame", nil, UIParent, "PortraitFrameTemplate,BackdropTemplate")
        f:Hide()
        self.sidebar = self:SidebarAvailable()
        self.layoutWidth = self.sidebar and 1064 or 940
        local contentX = self.sidebar and 160 or 24
        local shift = contentX - 24
        f:SetSize(self.layoutWidth, 660); self:Opaque(f, self.c.bg)
        if f.Bg then f.Bg:SetVertexColor(0.85, 0.77, 0.65, 1) end
        if f.SetTitle then f:SetTitle(S.title)
        elseif f.TitleText then f.TitleText:SetText(S.title) end
        if f.SetPortraitToAsset then f:SetPortraitToAsset(S.icon)
        elseif f.portrait then f.portrait:SetTexture(S.icon) end
        self:RestorePosition(f, "journalPosition")
        f:SetFrameStrata("HIGH"); f:SetClampedToScreen(true); f:SetMovable(true); f:EnableMouse(true)
        _G.SkinningLogSolFrame = f; table.insert(UISpecialFrames, "SkinningLogSolFrame")
        local headerLevel = f:GetFrameLevel()
        for _, part in ipairs({ f.NineSlice or f, f.TitleContainer or f, f.CloseButton or f }) do
            headerLevel = math.max(headerLevel, part:GetFrameLevel())
        end
        local titleDrag = CreateFrame("Frame", nil, f)
        titleDrag:SetPoint("TOPLEFT", 58, -1); titleDrag:SetSize(self.layoutWidth - 95, 23); titleDrag:SetFrameLevel(headerLevel + 1)
        self:DragHandle(titleDrag, f, "journalPosition"); self.titleDrag = titleDrag
        local drag = CreateFrame("Frame", nil, f); drag:SetPoint("TOPLEFT", 60, -24); drag:SetSize(self.layoutWidth - 110, 54)
        drag:SetFrameLevel(headerLevel + 1)
        self:DragHandle(drag, f, "journalPosition"); self.headerDrag = drag
        self:Text(drag, "Field journal", 7, 5, 17, self.c.gold)
        local rankX = self.sidebar and 495 or 393
        self.rankLabel = self:OneLine(drag, "", rankX, 3, 12, self.c.gold, 475)
        self.rankFill = self:Bar(drag, rankX, 24, self.sidebar and 475 or 385, 0, self.c.blue, 20)
        self.rankXP = self:OneLine(self.rankFill, "", 0, 0, 10, self.c.text, self.rankFill:GetWidth() - 14)
        self.rankXP:ClearAllPoints(); self.rankXP:SetPoint("CENTER"); self.rankXP:SetHeight(14)
        self.rankXP:SetJustifyH("CENTER"); self.rankXP:SetJustifyV("MIDDLE")
        self:Tooltip(drag, "How XP works", { "This is addon research XP. It does not change character level or profession skill." })
        local close = f.CloseButton or CreateFrame("Button", nil, f, "UIPanelCloseButton")
        if not f.CloseButton then close:SetPoint("TOPRIGHT", -5, -5) end
        close:SetScript("OnClick", function() f:Hide() end)
        local tabs = { { "guide", "Creatures", 151, "Ability_Hunter_BeastCall" }, { "materials", "Materials", 145, "INV_Misc_LeatherScrap_03" },
            { "atlas", "Hunting grounds", 168, "INV_Misc_Map_01" }, { "session", "Expedition", 141, "INV_Misc_Bag_10" },
            { "research", "Research", 130, "INV_Misc_Book_09" }, { "settings", "Preferences", 151, "Trade_Engineering" } }
        if self.sidebar then
            local background = f:CreateTexture(nil, "BORDER", nil, -8)
            background:SetPoint("TOPLEFT", 1, -80); background:SetSize(self.layoutWidth - 3, 535)
            self:ApplyAtlas(background, "Legacy-Tree-Frame-background")
            self.sidebarDivider = f:CreateTexture(nil, "ARTWORK")
            self.sidebarDivider:SetPoint("TOPLEFT", 135, -80); self.sidebarDivider:SetSize(12, 535)
            self:ApplyAtlas(self.sidebarDivider, "Legacy-Tree-Frame-divider-Vertical")
            self.pageTitle = self:OneLine(f, "", contentX, 81, 16, self.c.gold, 650)
        end
        local x = 18
        for i, tab in ipairs(tabs) do
            if self.sidebar then self.nav[tab[1]] = self:SidebarButton(f, tab[1], tab[2], "Interface\\Icons\\" .. tab[4], 113 + (i - 1) * 82)
            else self.nav[tab[1]] = self:Button(f, tab[2], x, 77, tab[3] - 5, 30, function() self:SelectTab(tab[1]) end, false, "tab") end
            x = x + tab[3]
        end
        self.context = self:OneLine(f, "", contentX, 112, 11, self.c.muted, 660)
        self.scopeButton = self:Dropdown(f, "All characters", 738 + shift, 103, 178,
            { { "all", "All characters" }, { "character", "This character" } }, M.db.settings.scope, function(scope)
                M.db.settings.scope = scope; self.selected = nil; self.page = 1; self:Refresh()
                if S.Maps then S.Maps:Dirty() end
            end)
        self.content = CreateFrame("Frame", nil, f); self.content:SetPoint("TOPLEFT", contentX, -144); self.content:SetSize(892, 463)
        self.searchBox = self:Input(f, contentX, 144, 310, "Search creatures, materials or zones...", function(text)
            self.search = text; self.page = 1; self:Refresh()
        end)
        self.materialSearchBox = self:Input(f, contentX, 144, 350, "Search materials...", function(text)
            self.materialSearch = text; self.page = 1; self:Refresh()
        end)
        self:Line(f, contentX - 3, 619, 896)
        self.footer = self:OneLine(f, "", contentX, 633, 10, self.c.muted, 635)
        self:Button(f, "-", 713 + shift, 626, 27, 23, function() M.db.settings.journalScale = math.max(0.65, M.db.settings.journalScale - 0.05); self:Scale() end)
        self:Button(f, "+", 745 + shift, 626, 27, 23, function() M.db.settings.journalScale = math.min(1.2, M.db.settings.journalScale + 0.05); self:Scale() end)
        self:Button(f, "Help", 787 + shift, 626, 130, 23, function() S:Welcome(true) end)
        local elapsed = 0
        f:SetScript("OnUpdate", function(_, delta)
            elapsed = elapsed + delta
            if elapsed >= 1 then elapsed = 0; self:Tick() end
        end)
        f:SetScript("OnHide", function() self.searchBox:ClearFocus(); self.materialSearchBox:ClearFocus(); if self.menu then self.menu:Hide() end end)
        -- Publish only a fully constructed journal. Failed construction must
        -- never leave a partial frame that later opens skip rebuilding.
        self.frame = f; self:Scale()
    end)
    self.buildAttempts = 0
end

function U:Scale()
    if self.frame then self.frame:SetScale(math.min(M.db.settings.journalScale or 0.9, (UIParent:GetWidth() - 30) / self.layoutWidth, (UIParent:GetHeight() - 30) / 660)) end
end

function U:Clear()
    self.clockLabel, self.rateLabel = nil, nil
    for _, w in ipairs(self.widgets) do
        w:Hide()
        if w.SetScript then
            for _, event in ipairs({ "OnClick", "OnEnter", "OnLeave", "OnTextChanged", "OnEscapePressed", "OnDragStart", "OnDragStop" }) do pcall(w.SetScript, w, event, nil) end
        end
    end
    self.widgets = {}; for _, pool in pairs(self.pool) do pool.used = 0 end
end

function U:SelectTab(tab)
    self.tab = tab; self.page = 1
    if self.menu then self.menu:Hide() end
    self:Refresh()
end

function U:Toggle()
    self:Build(); if self.frame:IsShown() then self.frame:Hide() else self.frame:Show(); self:Refresh() end
end

function U:Open(tab)
    self:Build(); self.frame:Show(); if tab then self.tab = tab end; self:Refresh()
end

function U:OpenCreature(key)
    if not M:Data().creatures[key] and M.db.all.creatures[key] then M.db.settings.scope = "all" end
    self.selected = key; self:Open("guide")
end

function U:Tick()
    local session = M:Session()
    local elapsed = session.skins > 0 and time() - session.start or 0
    if self.clockLabel then self.clockLabel:SetText(S.Duration(elapsed)) end
    if self.rateLabel then self.rateLabel:SetText(elapsed >= 60 and string.format("%.0f", session.skins / elapsed * 3600) or "--") end
end

function U:Empty(parent, title, body, y)
    self:Icon(parent, "Interface\\Icons\\INV_Misc_Book_09", 37, y or 75, 64)
    self:Text(parent, title, 125, (y or 75) + 5, 21, self.c.gold, 680)
    self:Text(parent, body, 125, (y or 75) + 42, 13, self.c.muted, 620)
    self:Button(parent, "Help", 125, (y or 75) + 119, 150, 30, function() S:Welcome(true) end)
end

function U:Pagination(parent, count, size, y, width)
    width = width or 892
    local pages = math.max(1, math.ceil(count / size)); self.page = math.min(self.page, pages)
    self:Text(parent, S.N(count, "entry", "entries") .. "  /  " .. S.Fmt("Page %d / %d", self.page, pages), 5, y + 8, 10, self.c.muted, width - 230)
    if self.page > 1 then self:Button(parent, "Previous", width - 212, y, 100, 27, function() self.page = self.page - 1; self:Refresh() end) end
    if self.page < pages then self:Button(parent, "Next", width - 104, y, 100, 27, function() self.page = self.page + 1; self:Refresh() end) end
end

function U:Refresh()
    if not self.frame or not self.frame:IsShown() then return end
    self:Clear(); self.collect = true
    local data, settings = M:Data(), M.db.settings
    local state = S.Research:State(); local rank, nextRank = S.Research:Rank(state.xp)
    self.rankLabel:SetText(L(state.title or rank.name))
    self.rankXP:SetText(nextRank and (state.xp .. " XP  ·  " .. S.Fmt("%d XP to next rank", nextRank.xp - state.xp)) or L("Highest rank reached"))
    self:SetBar(self.rankFill, nextRank and (state.xp - rank.xp) / (nextRank.xp - rank.xp) or 1)
    self.context:SetText(S.demo and L("Fictional sample data") or (not settings.enabled and L("Tracking paused") or (S.Fmt("%d species discovered", S.Count(data.creatures)) .. "  ·  " .. S.Fmt("%d creatures skinned", data.skins))))
    self.scopeButton.label:SetText(L(settings.scope == "all" and "All characters" or "This character") .. "  v")
    self.scopeButton:SetScript("OnClick", function()
        self:Menu(self.scopeButton, { { "all", "All characters" }, { "character", "This character" } }, settings.scope, function(scope)
            settings.scope = scope; self.selected = nil; self.page = 1; self:Refresh(); if S.Maps then S.Maps:Dirty() end
        end)
    end)
    for name, b in pairs(self.nav) do
        self:PaintButton(b, name == self.tab)
    end
    if self.sidebar then self.pageTitle:SetText(L(self.nav[self.tab].pageLabel)) end
    self.searchBox:SetShown(self.tab == "guide")
    self.materialSearchBox:SetShown(self.tab == "materials")
    self.scopeButton:SetShown(self.tab == "guide" or self.tab == "materials" or self.tab == "atlas")
    if self.tab == "research" or self.tab == "session" then
        self.context:SetText(L("This character") .. " · " .. S.Fmt("%d species discovered", S.Count((S.demo and M:Data() or M.db.characters[M.character]).creatures)))
    end
    if self.tab == "guide" then self:Guide()
    elseif self.tab == "materials" then self:Materials()
    elseif self.tab == "atlas" then self:Atlas()
    elseif self.tab == "session" then self:Expedition()
    elseif self.tab == "research" then self:Research()
    else self:Settings() end
    self.collect = false; self:Tick()
end

function U:Export()
    self:Static(function()
        if not self.exportFrame then
            local popup = self:Panel(UIParent, 0, 0, 710, 430)
            popup:ClearAllPoints(); popup:SetPoint("CENTER"); popup:SetFrameStrata("DIALOG")
            self:Text(popup, "Copy CSV", 20, 17, 16, self.c.gold)
            self:Text(popup, "Copied with Ctrl+C. Escape closes this window.", 20, 47, 12, self.c.muted)
            local scroll = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", 20, -79); scroll:SetSize(650, 320)
            local edit = CreateFrame("EditBox", nil, scroll)
            edit:SetMultiLine(true); edit:SetFont(STANDARD_TEXT_FONT, 12, ""); edit:SetAutoFocus(false); edit:SetWidth(645)
            edit:SetScript("OnEscapePressed", function() popup:Hide() end); scroll:SetScrollChild(edit); popup.edit = edit
            local close = CreateFrame("Button", nil, popup, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -3, -3)
            close:SetScript("OnClick", function() popup:Hide() end)
            _G.SkinningLogSolExport = popup; table.insert(UISpecialFrames, "SkinningLogSolExport"); self.exportFrame = popup
        end
        self.exportFrame.edit:SetText(M:CSV()); self.exportFrame:Show(); self.exportFrame.edit:SetFocus(); self.exportFrame.edit:HighlightText()
    end)
end
