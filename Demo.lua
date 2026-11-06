local _, S = ...

-- Fictional sample observations. Never written to SavedVariables or mixed with live tracking.
function S:ToggleDemo()
    if self.demo then self.demo = nil else
        local data = self.Model:Empty()
        local creatures = {
            { 1131, "Winter Wolf", 8, "Wolf", 112, 1426, "Dun Morogh", 0.45, 0.56 },
            { 1128, "Young Black Bear", 6, "Bear", 64, 1426, "Dun Morogh", 0.41, 0.61 },
            { 1196, "Ice Claw Bear", 12, "Bear", 38, 1426, "Dun Morogh", 0.49, 0.54 },
            { 1138, "Snow Tracker Wolf", 9, "Wolf", 26, 1426, "Dun Morogh", 0.53, 0.48 },
            { 1190, "Mountain Boar", 10, "Boar", 18, 1432, "Loch Modan", 0.32, 0.70 },
            { 1186, "Elder Black Bear", 11, "Bear", 8, 1432, "Loch Modan", 0.39, 0.42 },
            { 1995, "Strigid Owl", 7, "Owl", 4, 1438, "Teldrassil", 0.48, 0.56 },
            { 1998, "Webwood Lurker", 5, "Spider", 2, 1438, "Teldrassil", 0.56, 0.40 },
        }
        local session = self.Model:Empty()
        session.start = time() - 1380
        for _, c in ipairs(creatures) do
            for i = 1, c[5] do
                local items = { [2318] = { count = i % 3 == 0 and 2 or 1, name = "Light Leather",
                    icon = "Interface\\Icons\\INV_Misc_LeatherScrap_03", link = "item:2318" } }
                if i % 11 == 0 then items[783] = { count = 1, name = "Light Hide", icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01", link = "item:783" } end
                local record = { npcID = c[1], name = c[2], level = c[3], family = c[4],
                    mapID = c[6], zone = c[7], x = c[8] + ((i * 7) % 11 - 5) / 400,
                    y = c[9] + ((i * 3) % 9 - 4) / 400, items = items, at = time() - (c[5] - i) * 38 }
                self.Model:Aggregate(data, record)
                if c[1] == 1131 and i > 70 then self.Model:Aggregate(session, record) end
            end
        end
        self.demo = { data = data, session = session, goal = { itemID = 2318, name = "Light Leather", target = 100,
            baseline = data.items[2318].count - 63 } }
    end
    if self.UI then self.UI.selected = nil; self.UI.page = 1; self.UI:Refresh() end
    if self.HUD then self.HUD:Refresh() end
    if self.Maps then self.Maps:Dirty() end
end
