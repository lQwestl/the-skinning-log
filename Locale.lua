local _, S = ...
local de = {
    ["Field journal"] = "Feldjournal", ["Creatures"] = "Kreaturen", ["Materials"] = "Materialien",
    ["Hunting grounds"] = "Jagdgebiete", ["Expedition"] = "Expedition", ["Research"] = "Forschung",
    ["Preferences"] = "Einstellungen", ["Help"] = "Hilfe", ["Close"] = "Schließen",
    ["All characters"] = "Alle Charaktere", ["This character"] = "Dieser Charakter",
    ["All creatures"] = "Alle Kreaturen", ["Favorites"] = "Favoriten", ["Mastered"] = "Gemeistert",
    ["Most materials"] = "Meiste Materialien", ["Yield per skin"] = "Ertrag pro Tier",
    ["Most skinned"] = "Meiste Häutungen", ["Recently seen"] = "Zuletzt gesehen", ["Name"] = "Name",
    ["Search creatures, materials or zones..."] = "Kreatur, Material oder Gebiet suchen...",
    ["Search materials..."] = "Material suchen...", ["Save note"] = "Notiz speichern",
    ["Field note..."] = "Feldnotiz...", ["Favorite"] = "Merken", ["Favorited"] = "Gemerkt",
    ["Discovered"] = "Entdeckt", ["Tracker"] = "Fährtenleser", ["Expert"] = "Experte", ["Master"] = "Meister",
    ["Skinned"] = "Gehäutet", ["Collected"] = "Gesammelt", ["Per skin"] = "Pro Tier",
    ["Observed drops"] = "Gesammelte Beute", ["Quantity"] = "Menge", ["Frequency"] = "Häufigkeit",
    ["Show on map"] = "Auf Karte zeigen", ["Set waypoint"] = "Wegpunkt setzen",
    ["Best sources"] = "Beste Quellen", ["Estimated value"] = "Geschätzter Wert",
    ["AH estimate"] = "AH-Schätzung", ["Vendor"] = "Händler", ["No price"] = "Kein Preis",
    ["Collection goal"] = "Sammelziel", ["Set goal"] = "Ziel setzen", ["Clear goal"] = "Ziel löschen",
    ["New expedition"] = "Neue Expedition", ["Recent gathers"] = "Letzte Häutungen",
    ["Session history"] = "Verlauf", ["Current session"] = "Aktuelle Runde",
    ["Elapsed"] = "Dauer", ["Skins / hour"] = "Tiere / Stunde", ["Session XP"] = "Runden-XP",
    ["Tracking paused"] = "Aufzeichnung pausiert", ["Tracking active"] = "Aufzeichnung aktiv",
    ["Sample journal"] = "Beispieljournal", ["Exit sample"] = "Beispiel verlassen",
    ["Fictional sample data"] = "Fiktive Beispieldaten", ["Previous"] = "Zurück", ["Next"] = "Weiter",
    ["New discovery"] = "Neue Entdeckung", ["Goal complete"] = "Sammelziel erreicht",
    ["Rank earned"] = "Neuer Forschungsrang", ["Mastery earned"] = "Forschungsstufe erreicht",
    ["Discovered: %s"] = "Entdeckt: %s", ["Goal complete: %s"] = "Sammelziel erreicht: %s",
    ["%s · %d species discovered"] = "%s · %d Arten entdeckt",
    ["%d materials collected"] = "%d Materialien gesammelt",
    ["%d creatures skinned"] = "%d Tiere gehäutet", ["%d species discovered"] = "%d Arten entdeckt",
    ["%d zones explored"] = "%d Gebiete erforscht", ["%d XP to next rank"] = "%d XP bis zum nächsten Rang",
    ["%d more skins to %s"] = "Noch %d Häutungen bis %s", ["Page %d / %d"] = "Seite %d / %d",
    ["Level %s"] = "Stufe %s", ["First recorded %s"] = "Erstmals erfasst: %s",
    ["%d skinned · %d materials"] = "%d gehäutet · %d Materialien",
    ["%d skins sampled"] = "%d Häutungen erfasst", ["Last visit: %s"] = "Letzter Besuch: %s",
    ["Skinning"] = "Kürschnerei", ["Skill"] = "Beruf", ["Expand"] = "Ausklappen",
    ["Collapse"] = "Einklappen", ["Open journal"] = "Journal öffnen", ["Open world map"] = "Weltkarte öffnen",
    ["Click to inspect"] = "Zum Ansehen klicken", ["Right click for a waypoint"] = "Rechtsklick: Wegpunkt",
    ["Your recorded positions"] = "Deine erfassten Positionen", ["Clear map filter"] = "Kartenfilter löschen",
    ["World map pins"] = "Weltkartenmarkierungen", ["Minimap gathering pins"] = "Jagdmarkierungen auf Minikarte",
    ["Live tracker"] = "Live-Anzeige", ["Minimap journal button"] = "Journal auf Minikarte",
    ["Discovery notifications"] = "Entdeckungsmeldungen", ["Notification sounds"] = "Benachrichtigungstöne",
    ["Animated notifications"] = "Animierte Meldungen", ["Creature tooltip notes"] = "Kreatur-Tooltips",
    ["Record skinning"] = "Häutungen aufzeichnen", ["On"] = "An", ["Off"] = "Aus",
    ["Journal size"] = "Journalgröße", ["Tracker size"] = "Anzeigegröße", ["Reset positions"] = "Positionen zurücksetzen",
    ["Copy CSV"] = "CSV kopieren", ["Welcome to your field journal"] = "Willkommen in deinem Feldjournal",
    ["Your next discovery starts with one skin."] = "Deine nächste Entdeckung beginnt mit einer Häutung.",
    ["Skin a creature"] = "Häute ein Tier", ["Inspect your discovery"] = "Sieh dir deine Entdeckung an",
    ["Choose your next goal"] = "Wähle dein nächstes Ziel", ["Start exploring"] = "Auf ins Abenteuer",
    ["Collect its loot. Your journal records the creature, materials and your location automatically."] = "Sammle die Beute ein. Das Journal erfasst das Tier, seine Materialien und deinen Standort automatisch.",
    ["Open a creature card to study its drops, build mastery and return to its hunting grounds."] = "Entdecke Beute, Forschungsstufen und Jagdgebiete auf der Kreaturenkarte.",
    ["Pin a material goal, earn research XP and follow your progress in the compact live tracker."] = "Setze ein Sammelziel, verdiene Forschungs-XP und verfolge deinen Fortschritt in der kompakten Live-Anzeige.",
    ["Your discoveries are waiting"] = "Deine Entdeckungen warten", ["No matching entries"] = "Keine passenden Einträge",
    ["Skin a creature and collect its loot to begin. You can explore a separate sample journal in Help."] = "Häute ein Tier und sammle die Beute ein. In der Hilfe findest du ein separates Beispieljournal.",
    ["Try a different search or filter."] = "Versuche eine andere Suche oder einen anderen Filter.",
    ["No recorded positions in this area yet."] = "In diesem Gebiet wurden noch keine Positionen erfasst.",
    ["Your rank"] = "Dein Rang", ["Research milestones"] = "Forschungsmeilensteine",
    ["How XP works"] = "So funktionieren XP", ["Next fieldwork"] = "Nächste Forschungsziele",
    ["Earned"] = "Erreicht", ["Locked"] = "Gesperrt", ["Wear title"] = "Titel wählen",
    ["Title selected"] = "Titel gewählt", ["Highest rank reached"] = "Höchster Rang erreicht",
    ["First steps"] = "Erste Spuren", ["Field collector"] = "Feldsammler", ["Naturalist"] = "Naturkundler",
    ["Trail explorer"] = "Wegbereiter", ["Seasoned explorer"] = "Weltenbummler",
    ["Creature expert"] = "Tierkenner", ["Master researcher"] = "Meisterforscher",
    ["A hundred hides"] = "Hundert Felle", ["Veteran skinner"] = "Erfahrener Kürschner",
    ["Field Apprentice"] = "Forschungslehrling", ["Pelt Tracker"] = "Fellkundiger",
    ["Trailfinder"] = "Fährtensucher", ["Beast Researcher"] = "Tierforscher",
    ["Seasoned Skinner"] = "Erfahrener Kürschner", ["Master Naturalist"] = "Meisternaturkundler",
    ["Keeper of the Wilds"] = "Hüter der Wildnis", ["Living Atlas"] = "Lebender Atlas",
    ["Prices are estimates from local Auctionator data or vendor prices."] = "Schätzungen aus lokalen Auctionator-Daten oder Händlerpreisen.",
    ["Frequencies use collected loot. Small samples vary."] = "Häufigkeiten basieren auf gesammelter Beute. Kleine Stichproben schwanken.",
    ["Map pins mark where you stood while skinning; they are not verified spawns."] = "Markierungen zeigen deinen Standort beim Häuten; es sind keine bestätigten Spawnpunkte.",
    ["Rates include travel and idle time. Available after one minute."] = "Die Rate enthält Reise- und Wartezeit. Verfügbar nach einer Minute.",
    ["This is addon research XP. It does not change character level or profession skill."] = "Dies sind Forschungs-XP des Addons. Sie ändern weder Charakterstufe noch Berufsfertigkeit.",
    ["Only new loot on the character that set this goal counts."] = "Nur neue Beute auf dem Charakter zählt, der das Ziel gesetzt hat.",
    ["Goals of 25+ materials grant 25 XP, up to twice per day."] = "Ziele ab 25 Materialien geben 25 XP, bis zu zweimal täglich.",
    ["Exit the sample journal to save changes."] = "Verlasse das Beispieljournal, um Änderungen zu speichern.",
    ["Enter a target from 1 to 999999."] = "Gib ein Ziel von 1 bis 999999 ein.",
    ["Field note saved."] = "Feldnotiz gespeichert.", ["No active goal"] = "Kein aktives Ziel",
    ["New species"] = "Neue Art", ["New zone"] = "Neues Gebiet", ["Successful skin"] = "Erfolgreiche Häutung",
    ["Observe a new species"] = "Entdecke eine neue Art", ["Explore a new zone"] = "Erforsche ein neues Gebiet",
    ["Unlocks an addon journal title."] = "Schaltet einen Titel im Addon frei.",
    ["Browse all discoveries"] = "Alle Entdeckungen ansehen", ["No completed expeditions yet."] = "Noch keine abgeschlossenen Expeditionen.",
    ["Copied with Ctrl+C. Escape closes this window."] = "Mit Strg+C kopieren. Escape schließt das Fenster.",
    ["Preview discovery"] = "Meldung testen", ["Preview only · no progress awarded"] = "Vorschau · kein Fortschritt vergeben",
    ["%d XP credited from earlier observations"] = "%d XP aus früheren Aufzeichnungen gutgeschrieben",
    ["Left click: journal · Right click: world map · Drag: move"] = "Linksklick: Journal · Rechtsklick: Weltkarte · Ziehen: verschieben",
    ["5 XP per skin. New species: +40 XP. New zone: +25 XP. Every recorded creature starts its own mastery journey."] = "5 XP pro Häutung. Neue Art: +40 XP. Neues Gebiet: +25 XP. Jede erfasste Art hat eigene Forschungsstufen.",
    ["10 / 50 / 100 skins of a species award +30 / 75 / 150 XP. Earn ranks, badges and journal titles as your research grows."] = "10 / 50 / 100 Häutungen einer Art geben +30 / 75 / 150 XP. Erforsche die Tierwelt und sammle Ränge, Abzeichen und Titel im Journal.",
    ["Goals of 25+ materials grant 25 XP, up to twice per day. Goals count only new loot. Discoveries and rank rewards persist between adventures."] = "Ziele ab 25 Materialien geben 25 XP, bis zu zweimal täglich. Nur neue Beute zählt. Entdeckungen und Forschungsränge bleiben gespeichert.",
    ["unknown"] = "unbekannt", ["Unknown zone"] = "Unbekanntes Gebiet", ["Unidentified creature"] = "Unbekannte Kreatur",
}
S.locale = GetLocale and GetLocale() or "enUS"
function S.L(text) return S.locale == "deDE" and (de[text] or text) or text end
local singularFormats = {
        ["%d species discovered"] = { "%d species discovered", "%d Art entdeckt" },
        ["%d creatures skinned"] = { "%d creature skinned", "%d Tier gehäutet" },
        ["%d materials collected"] = { "%d material collected", "%d Material gesammelt" },
        ["%d zones explored"] = { "%d zone explored", "%d Gebiet erforscht" },
        ["%d skins sampled"] = { "%d skin sampled", "%d Häutung erfasst" },
        ["%d more skins to %s"] = { "%d more skin to %s", "Noch %d Häutung bis %s" },
}
local germanNouns = { skin = "Häutung", skins = "Häutungen", material = "Material", materials = "Materialien",
    entry = "Eintrag", entries = "Einträge", species = "Arten", zone = "Gebiet", zones = "Gebiete" }
function S.Fmt(text, ...)
    local first, second = ...
    local fmt = S.L(text)
    if first == 1 and singularFormats[text] then fmt = singularFormats[text][S.locale == "deDE" and 2 or 1] end
    if text == "%s · %d species discovered" and second == 1 and S.locale == "deDE" then fmt = "%s · %d Art entdeckt" end
    if text == "%d skinned · %d materials" and second == 1 then fmt = S.locale == "deDE" and "%d gehäutet · %d Material" or "%d skinned · %d material" end
    return string.format(fmt, ...)
end
function S.N(n, singular, plural)
    if S.locale == "deDE" then
        local word = n == 1 and singular or (plural or singular .. "s")
        return n .. " " .. (germanNouns[word] or S.L(word))
    end
    return n .. " " .. (n == 1 and singular or (plural or singular .. "s"))
end
de["Skin loot notifications"] = "Beutehinweise beim Häuten"
de["%s · average %s materials/skin"] = "%s · Ø %s Material/Tier"
de["Total · observed rate"] = "Menge · Fundrate"
de["Small sample · observed rates may vary."] = "Kleine Stichprobe · Fundraten können schwanken."
de["Your species mastery"] = "Deine Artenkenntnis"
de["Field note"] = "Feldnotiz"
de["Material"] = "Material"
de["%d more materials · /tsl for details"] = "%d weitere Materialien · Details mit /tsl"
singularFormats["%d more materials · /tsl for details"] = { "%d more material · /tsl for details", "%d weiteres Material · Details mit /tsl" }
de["Skins"] = "Felle"
de["Journal creation failed twice. Use /reload before trying again."] = "Der Journalaufbau ist zweimal fehlgeschlagen. Bitte vor dem nächsten Versuch /reload ausführen."
S.localeStrings = de
