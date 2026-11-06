local _, S = ...
local M = S.Model
S.Research = {}
local R = S.Research
R.ranks = {
    { xp = 0, name = "Field Apprentice", icon = "Interface\\Icons\\INV_Misc_Book_09" },
    { xp = 250, name = "Pelt Tracker", icon = "Interface\\Icons\\Ability_Tracking" },
    { xp = 800, name = "Trailfinder", icon = "Interface\\Icons\\Ability_Hunter_Pathfinding" },
    { xp = 1800, name = "Beast Researcher", icon = "Interface\\Icons\\Ability_Hunter_BeastCall" },
    { xp = 3500, name = "Seasoned Skinner", icon = S.icon },
    { xp = 6500, name = "Master Naturalist", icon = "Interface\\Icons\\INV_Misc_Book_11" },
    { xp = 11000, name = "Keeper of the Wilds", icon = "Interface\\Icons\\Ability_Druid_DemoralizingRoar" },
    { xp = 18000, name = "Living Atlas", icon = "Interface\\Icons\\INV_Misc_Map_01" },
}
R.mastery = { { count = 10, xp = 30 }, { count = 50, xp = 75 }, { count = 100, xp = 150 } }

function R:Baseline(data)
    local xp = (data.skins or 0) * 5 + S.Count(data.creatures) * 40
    for id, z in pairs(data.zones) do if tonumber(id) and tonumber(id) > 0 and z.skins > 0 then xp = xp + 25 end end
    for _, c in pairs(data.creatures) do
        for _, m in ipairs(self.mastery) do if c.skins >= m.count then xp = xp + m.xp end end
    end
    return xp
end

function R:Init()
    for _, data in pairs(M.db.characters) do
        if not data.research then
            local credit = self:Baseline(data)
            data.research = { version = 1, xp = credit, migratedXP = credit, goals = 0, recent = {} }
        end
    end
end

function R:State()
    if S.demo then
        S.demo.research = S.demo.research or { version = 1, xp = self:Baseline(S.demo.data), goals = 2, recent = {} }
        return S.demo.research
    end
    return M.db.characters[M.character].research
end

function R:Rank(xp)
    local level = 1
    for i, r in ipairs(self.ranks) do if xp >= r.xp then level = i end end
    return self.ranks[level], self.ranks[level + 1], level
end

function R:Award(amount, reason, quiet)
    local state = M.db.characters[M.character].research
    local _, _, before = self:Rank(state.xp)
    state.xp = state.xp + amount
    table.insert(state.recent, 1, { xp = amount, reason = reason, at = time() })
    while #state.recent > 12 do table.remove(state.recent) end
    local rank, _, after = self:Rank(state.xp)
    if after > before and not quiet and M.db.settings.announce and S.Notice then
        S:Notice({ kind = "rank", title = "Rank earned", name = S.L(rank.name), icon = rank.icon,
            subtitle = S.L("Unlocks an addon journal title.") })
    end
end

function R:Record(record, oldSkins, newZone)
    local xp, reasons = 5, { S.L("Successful skin") .. " +5" }
    if oldSkins == 0 then xp = xp + 40; reasons[#reasons + 1] = S.L("New species") .. " +40" end
    if newZone then xp = xp + 25; reasons[#reasons + 1] = S.L("New zone") .. " +25" end
    local milestone
    for _, m in ipairs(self.mastery) do
        if oldSkins < m.count and oldSkins + 1 >= m.count then xp = xp + m.xp; milestone = m end
    end
    self:Award(xp, table.concat(reasons, " · "))
    if milestone and M.db.settings.announce and S.Notice then
        S:Notice({ kind = "mastery", title = "Mastery earned", name = record.name, npcID = record.npcID,
            family = record.family, key = M:CreatureKey(record), subtitle = S.L(S.Rank(milestone.count)) .. " · " .. S.N(milestone.count, "skin"), xp = milestone.xp })
    end
    return xp, reasons
end

function R:GoalComplete(goal)
    if goal.researchAwarded then return 0 end
    goal.researchAwarded = true
    local state = M.db.characters[M.character].research
    state.goals = (state.goals or 0) + 1
    local today = date("%Y-%m-%d")
    if state.goalDay ~= today then state.goalDay, state.goalAwards = today, 0 end
    if goal.target < 25 or (state.goalAwards or 0) >= 2 then return 0 end
    state.goalAwards = (state.goalAwards or 0) + 1
    self:Award(25, S.L("Goal complete") .. ": " .. goal.name)
    return 25
end

function R:Badges(data)
    local experts, masters, zones = 0, 0, 0
    for id, zone in pairs(data.zones) do if tonumber(id) and tonumber(id) > 0 and zone.skins > 0 then zones = zones + 1 end end
    for _, c in pairs(data.creatures) do if c.skins >= 50 then experts = experts + 1 end; if c.skins >= 100 then masters = masters + 1 end end
    return {
        { name = "First steps", value = S.Count(data.creatures), target = 1, icon = "Interface\\Icons\\Ability_Tracking" },
        { name = "Field collector", value = S.Count(data.creatures), target = 10, icon = "Interface\\Icons\\INV_Misc_Book_09" },
        { name = "Naturalist", value = S.Count(data.creatures), target = 25, icon = "Interface\\Icons\\Ability_Hunter_BeastCall" },
        { name = "Trail explorer", value = zones, target = 3, icon = "Interface\\Icons\\INV_Misc_Map_01" },
        { name = "A hundred hides", value = data.skins, target = 100, icon = S.icon },
        { name = "Creature expert", value = experts, target = 1, icon = "Interface\\Icons\\Ability_Hunter_Pet_Cat" },
        { name = "Master researcher", value = masters, target = 1, icon = "Interface\\Icons\\INV_Misc_Book_11" },
        { name = "Veteran skinner", value = data.skins, target = 500, icon = "Interface\\Icons\\INV_Misc_Pelt_Bear_03" },
    }
end

function R:NextCreature(data)
    local chosen, left
    for _, c in pairs(data.creatures) do
        local _, _, goal = S.Rank(c.skins)
        local remain = goal - c.skins
        if remain > 0 and (not left or remain < left or (remain == left and c.name < chosen.name)) then chosen, left = c, remain end
    end
    return chosen, left
end

local familyIcons = {
        cat = "Cat", katze = "Cat", wolf = "Wolf", bear = "Bear", ["bär"] = "Bear",
        boar = "Boar", eber = "Boar", raptor = "Raptor", tallstrider = "TallStrider", ebenenschreiter = "TallStrider", weitschreiter = "TallStrider",
        spider = "Spider", spinne = "Spider", turtle = "Turtle", ["schildkröte"] = "Turtle",
        crocolisk = "Crocolisk", krokilisk = "Crocolisk", hyena = "Hyena", ["hyäne"] = "Hyena",
        owl = "Owl", eule = "Owl", bat = "Bat", fledermaus = "Bat", scorpid = "Scorpid", skorpion = "Scorpid",
        crab = "Crab", krabbe = "Crab", gorilla = "Gorilla",
        ["кошка"] = "Cat", ["кот"] = "Cat", ["волк"] = "Wolf", ["медведь"] = "Bear",
        ["вепрь"] = "Boar", ["кабан"] = "Boar", ["раптор"] = "Raptor", ["долгоног"] = "TallStrider",
        ["паук"] = "Spider", ["черепаха"] = "Turtle", ["кроколиск"] = "Crocolisk", ["гиена"] = "Hyena",
        ["сова"] = "Owl", ["нетопырь"] = "Bat", ["летучая мышь"] = "Bat", ["скорпид"] = "Scorpid",
        ["краб"] = "Crab", ["горилла"] = "Gorilla",
}
function S:FamilyIcon(family)
    local icon = familyIcons[(family or ""):lower()]
    return icon and ("Interface\\Icons\\Ability_Hunter_Pet_" .. icon) or "Interface\\Icons\\Ability_Tracking"
end
