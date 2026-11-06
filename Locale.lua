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
    ["Skin loot notifications"] = "Beutehinweise beim Häuten",
    ["%s · average %s materials/skin"] = "%s · Ø %s Material/Tier",
    ["Total · observed rate"] = "Menge · Fundrate",
    ["Small sample · observed rates may vary."] = "Kleine Stichprobe · Fundraten können schwanken.",
    ["Your species mastery"] = "Deine Artenkenntnis",
    ["Field note"] = "Feldnotiz",
    ["Material"] = "Material",
    ["%d more materials · /tsl for details"] = "%d weitere Materialien · Details mit /tsl",
    ["Skins"] = "Felle",
    ["Journal creation failed twice. Use /reload before trying again."] = "Der Journalaufbau ist zweimal fehlgeschlagen. Bitte vor dem nächsten Versuch /reload ausführen.",
    ["10 / 50 / 100 skins: +30 / 75 / 150 XP"] = "10 / 50 / 100 Häutungen: +30 / 75 / 150 XP",
    ["Successful skin: 5 XP"] = "Erfolgreiche Häutung: 5 XP",
    ["New species: +40 XP"] = "Neue Art: +40 XP",
    ["New zone: +25 XP"] = "Neues Gebiet: +25 XP",
}

local ru = {
    ["Field journal"] = "Полевой журнал", ["Creatures"] = "Существа", ["Materials"] = "Материалы",
    ["Hunting grounds"] = "Охотничьи угодья", ["Expedition"] = "Экспедиция", ["Research"] = "Исследования",
    ["Preferences"] = "Настройки", ["Help"] = "Помощь", ["Close"] = "Закрыть",
    ["All characters"] = "Все персонажи", ["This character"] = "Этот персонаж",
    ["All creatures"] = "Все существа", ["Favorites"] = "Избранное", ["Mastered"] = "Изученные",
    ["Most materials"] = "Больше всего материалов", ["Yield per skin"] = "Добыча со шкуры",
    ["Most skinned"] = "Чаще освежеванные", ["Recently seen"] = "Недавние", ["Name"] = "Название",
    ["Search creatures, materials or zones..."] = "Поиск существ, материалов или зон...",
    ["Search materials..."] = "Поиск материалов...", ["Save note"] = "Сохранить",
    ["Field note..."] = "Полевая заметка...", ["Favorite"] = "В избранное", ["Favorited"] = "В избранном",
    ["Discovered"] = "Открыто", ["Tracker"] = "Следопыт", ["Expert"] = "Эксперт", ["Master"] = "Мастер",
    ["Skinned"] = "Снято шкур", ["Collected"] = "Собрано", ["Per skin"] = "За шкуру",
    ["Observed drops"] = "Замеченная добыча", ["Quantity"] = "Количество", ["Frequency"] = "Шанс",
    ["Show on map"] = "Показать на карте", ["Set waypoint"] = "Точка назначения",
    ["Best sources"] = "Лучшие источники", ["Estimated value"] = "Оценочная стоимость",
    ["AH estimate"] = "Оценка аукциона", ["Vendor"] = "Торговец", ["No price"] = "Нет цены",
    ["Collection goal"] = "Цель сбора", ["Set goal"] = "Задать цель", ["Clear goal"] = "Сбросить цель",
    ["New expedition"] = "Новая экспедиция", ["Recent gathers"] = "Последние сборы",
    ["Session history"] = "История сессий", ["Current session"] = "Текущая сессия",
    ["Elapsed"] = "Время", ["Skins / hour"] = "Шкур в час", ["Session XP"] = "Опыт сессии",
    ["Tracking paused"] = "Запись на паузе", ["Tracking active"] = "Запись активна",
    ["Sample journal"] = "Пример журнала", ["Exit sample"] = "Выйти из примера",
    ["Fictional sample data"] = "Демонстрационные данные", ["Previous"] = "Назад", ["Next"] = "Далее",
    ["New discovery"] = "Новое открытие", ["Goal complete"] = "Цель достигнута",
    ["Rank earned"] = "Получен новый ранг", ["Mastery earned"] = "Мастерство повышено",
    ["Discovered: %s"] = "Открыто: %s", ["Goal complete: %s"] = "Цель достигнута: %s",
    ["%s · %d species discovered"] = "%s · обнаружено видов: %d",
    ["%d materials collected"] = "Собрано материалов: %d",
    ["%d creatures skinned"] = "Освежевано существ: %d", ["%d species discovered"] = "Обнаружено видов: %d",
    ["%d zones explored"] = "Исследовано зон: %d", ["%d XP to next rank"] = "%d опыта до след. ранга",
    ["%d more skins to %s"] = "Еще %d шкур до %s", ["Page %d / %d"] = "Страница %d / %d",
    ["Level %s"] = "Уровень %s", ["First recorded %s"] = "Впервые записано: %s",
    ["%d skinned · %d materials"] = "%d освежевано · %d материалов",
    ["%d skins sampled"] = "Учтено шкур: %d", ["Last visit: %s"] = "Последний визит: %s",
    ["Skinning"] = "Снятие шкур", ["Skill"] = "Навык", ["Expand"] = "Развернуть",
    ["Collapse"] = "Свернуть", ["Open journal"] = "Открыть журнал", ["Open world map"] = "Открыть карту мира",
    ["Click to inspect"] = "Нажмите для просмотра", ["Right click for a waypoint"] = "Правый клик: точка на карте",
    ["Your recorded positions"] = "Ваши записанные точки", ["Clear map filter"] = "Сбросить фильтр карты",
    ["World map pins"] = "Метки на карте мира", ["Minimap gathering pins"] = "Метки на миникарте",
    ["Live tracker"] = "Панель слежения", ["Minimap journal button"] = "Кнопка у миникарты",
    ["Discovery notifications"] = "Оповещения об открытиях", ["Notification sounds"] = "Звуки оповещений",
    ["Animated notifications"] = "Анимация оповещений", ["Creature tooltip notes"] = "Подсказки у существ",
    ["Record skinning"] = "Запись снятия шкур", ["On"] = "Вкл", ["Off"] = "Выкл",
    ["Journal size"] = "Размер журнала", ["Tracker size"] = "Размер панели", ["Reset positions"] = "Сброс позиций",
    ["Copy CSV"] = "Скопировать CSV", ["Welcome to your field journal"] = "Добро пожаловать в полевой журнал",
    ["Your next discovery starts with one skin."] = "Ваше следующее открытие начинается с одной шкуры.",
    ["Skin a creature"] = "Освежуйте существо", ["Inspect your discovery"] = "Изучите открытие",
    ["Choose your next goal"] = "Выберите следующую цель", ["Start exploring"] = "Начать исследование",
    ["Collect its loot. Your journal records the creature, materials and your location automatically."] = "Соберите добычу. Журнал автоматически запишет существо, материалы и ваше местоположение.",
    ["Open a creature card to study its drops, build mastery and return to its hunting grounds."] = "Откройте карточку существа, чтобы изучить добычу, повысить мастерство и вернуться в места охоты.",
    ["Pin a material goal, earn research XP and follow your progress in the compact live tracker."] = "Закрепите цель по материалам, получайте опыт исследований и следите за прогрессом на панели.",
    ["Your discoveries are waiting"] = "Ваши открытия ждут вас", ["No matching entries"] = "Ничего не найдено",
    ["Skin a creature and collect its loot to begin. You can explore a separate sample journal in Help."] = "Освежуйте существо и соберите добычу, чтобы начать. В разделе помощи можно открыть демонстрационный журнал.",
    ["Try a different search or filter."] = "Попробуйте изменить поиск или фильтр.",
    ["No recorded positions in this area yet."] = "В этой области пока нет записанных точек.",
    ["Your rank"] = "Ваш ранг", ["Research milestones"] = "Вехи исследований",
    ["How XP works"] = "Как работает опыт", ["Next fieldwork"] = "Следующая цель",
    ["Earned"] = "Получено", ["Locked"] = "Недоступно", ["Wear title"] = "Выбрать звание",
    ["Title selected"] = "Звание выбрано", ["Highest rank reached"] = "Достигнут максимальный ранг",
    ["First steps"] = "Первые шаги", ["Field collector"] = "Полевой сборщик", ["Naturalist"] = "Натуралист",
    ["Trail explorer"] = "Первопроходец", ["Seasoned explorer"] = "Опытный исследователь",
    ["Creature expert"] = "Знаток фауны", ["Master researcher"] = "Мастер-исследователь",
    ["A hundred hides"] = "Сотня шкур", ["Veteran skinner"] = "Ветеран свежевания",
    ["Field Apprentice"] = "Ученик исследователя", ["Pelt Tracker"] = "Охотник за шкурами",
    ["Trailfinder"] = "Следопыт троп", ["Beast Researcher"] = "Исследователь зверей",
    ["Seasoned Skinner"] = "Опытный кожевник", ["Master Naturalist"] = "Мастер-натуралист",
    ["Keeper of the Wilds"] = "Хранитель природы", ["Living Atlas"] = "Живой атлас",
    ["Prices are estimates from local Auctionator data or vendor prices."] = "Оценка стоимости основана на данных Auctionator или ценах торговцев.",
    ["Frequencies use collected loot. Small samples vary."] = "Шансы рассчитаны по собранной добыче. Небольшие выборки могут отличаться.",
    ["Map pins mark where you stood while skinning; they are not verified spawns."] = "Метки отмечают место снятия шкуры, а не гарантированные точки появления.",
    ["Rates include travel and idle time. Available after one minute."] = "Скорость учитывает перемещения и простой. Доступно через одну минуту.",
    ["This is addon research XP. It does not change character level or profession skill."] = "Это опыт исследований аддона. Он не меняет уровень персонажа или навык профессии.",
    ["Only new loot on the character that set this goal counts."] = "Учитывается только новая добыча персонажа, установившего цель.",
    ["Goals of 25+ materials grant 25 XP, up to twice per day."] = "Цели от 25 материалов дают 25 опыта (до 2 раз в день).",
    ["Exit the sample journal to save changes."] = "Выйдите из демонстрационного журнала, чтобы сохранять изменения.",
    ["Enter a target from 1 to 999999."] = "Введите цель от 1 до 999999.",
    ["Field note saved."] = "Полевая заметка сохранена.", ["No active goal"] = "Нет активной цели",
    ["New species"] = "Новый вид", ["New zone"] = "Новая зона", ["Successful skin"] = "Успешное снятие шкуры",
    ["Observe a new species"] = "Исследуйте новый вид", ["Explore a new zone"] = "Исследуйте новую зону",
    ["Unlocks an addon journal title."] = "Открывает звание в журнале аддона.",
    ["Browse all discoveries"] = "Просмотреть все открытия", ["No completed expeditions yet."] = "Завершенных экспедиций пока нет.",
    ["Copied with Ctrl+C. Escape closes this window."] = "Скопируйте с помощью Ctrl+C. Escape закрывает окно.",
    ["Preview discovery"] = "Тест оповещения", ["Preview only · no progress awarded"] = "Предпросмотр · прогресс не начисляется",
    ["%d XP credited from earlier observations"] = "Начислено %d опыта за прошлые наблюдения",
    ["Left click: journal · Right click: world map · Drag: move"] = "Левый клик: журнал · Правый клик: карта мира · Перетаскивание: переместить",
    ["5 XP per skin. New species: +40 XP. New zone: +25 XP. Every recorded creature starts its own mastery journey."] = "5 опыта за шкуру. Новый вид: +40 опыта. Новая зона: +25 опыта. Каждое записанное существо открывает свой путь мастерства.",
    ["10 / 50 / 100 skins of a species award +30 / 75 / 150 XP. Earn ranks, badges and journal titles as your research grows."] = "10 / 50 / 100 шкур вида дают +30 / 75 / 150 опыта. Получайте ранги, значки и звания по мере исследований.",
    ["Goals of 25+ materials grant 25 XP, up to twice per day. Goals count only new loot. Discoveries and rank rewards persist between adventures."] = "Цели от 25 материалов дают 25 опыта (до 2 раз в день). Учитывается только новая добыча. Прогресс сохраняется.",
    ["unknown"] = "неизвестно", ["Unknown zone"] = "Неизвестная зона", ["Unidentified creature"] = "Неопознанное существо",
    ["Skin loot notifications"] = "Оповещения о добыче со шкур",
    ["%s · average %s materials/skin"] = "%s · в среднем %s мат./шкура",
    ["Total · observed rate"] = "Всего · шанс",
    ["Small sample · observed rates may vary."] = "Малая выборка · шанс может отличаться.",
    ["Your species mastery"] = "Мастерство по виду",
    ["Field note"] = "Полевая заметка",
    ["Material"] = "Материал",
    ["%d more materials · /tsl for details"] = "Еще %d материалов · подробности: /tsl",
    ["Skins"] = "Шкуры",
    ["Journal creation failed twice. Use /reload before trying again."] = "Создание журнала не удалось дважды. Введите /reload перед новой попыткой.",
    ["10 / 50 / 100 skins: +30 / 75 / 150 XP"] = "10 / 50 / 100 шкур: +30 / 75 / 150 опыта",
    ["Successful skin: 5 XP"] = "Успешное снятие шкуры: 5 опыта",
    ["New species: +40 XP"] = "Новый вид: +40 опыта",
    ["New zone: +25 XP"] = "Новая зона: +25 опыта",
    -- Demo dataset entries
    ["Winter Wolf"] = "Зимний волк",
    ["Young Black Bear"] = "Молодой черный медведь",
    ["Ice Claw Bear"] = "Ледолапый медведь",
    ["Snow Tracker Wolf"] = "Снежный волк-следопыт",
    ["Mountain Boar"] = "Горный вепрь",
    ["Elder Black Bear"] = "Старый черный медведь",
    ["Strigid Owl"] = "Стрижиная сова",
    ["Webwood Lurker"] = "Крадущийся паук Тенистой паутины",
    ["Light Leather"] = "Тонкая кожа",
    ["Light Hide"] = "Тонкая шкура",
    ["Dun Morogh"] = "Дун Морог",
    ["Loch Modan"] = "Лок Модан",
    ["Teldrassil"] = "Тельдрассил",
    ["Wolf"] = "Волк",
    ["Bear"] = "Медведь",
    ["Boar"] = "Вепрь",
    ["Owl"] = "Сова",
    ["Spider"] = "Паук",
}

local clientLocale = GetLocale and GetLocale() or "enUS"
S.locale = (clientLocale == "deDE") and "deDE" or "ruRU"

function S.GetLocale()
    if S.Model and S.Model.db and S.Model.db.settings and S.Model.db.settings.language then
        local lang = S.Model.db.settings.language
        if lang ~= "auto" then return lang end
    end
    return S.locale
end

function S.L(text)
    if not text then return "" end
    local loc = S.GetLocale()
    if loc == "ruRU" then
        return ru[text] or text
    elseif loc == "deDE" then
        return de[text] or text
    end
    return text
end

local function ruPlural(n, one, few, many)
    n = math.abs(math.floor(n or 0))
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 and mod100 ~= 11 then
        return one
    elseif mod10 >= 2 and mod10 <= 4 and (mod100 < 10 or mod100 >= 20) then
        return few
    else
        return many
    end
end

local singularFormats = {
    ["%d species discovered"] = { "%d species discovered", "%d Art entdeckt" },
    ["%d creatures skinned"] = { "%d creature skinned", "%d Tier gehäutet" },
    ["%d materials collected"] = { "%d material collected", "%d Material gesammelt" },
    ["%d zones explored"] = { "%d zone explored", "%d Gebiet erforscht" },
    ["%d skins sampled"] = { "%d skin sampled", "%d Häutung erfasst" },
    ["%d more skins to %s"] = { "%d more skin to %s", "Noch %d Häutung bis %s" },
    ["%d more materials · /tsl for details"] = { "%d more material · /tsl for details", "%d weiteres Material · Details mit /tsl" },
}

local ruSingularFormats = {
    ["%d species discovered"] = { "обнаружен %d вид", "обнаружено %d вида", "обнаружено %d видов" },
    ["%d creatures skinned"] = { "освежевано %d существо", "освежевано %d существа", "освежевано %d существ" },
    ["%d materials collected"] = { "собран %d материал", "собрано %d материала", "собрано %d материалов" },
    ["%d zones explored"] = { "исследована %d зона", "исследовано %d зоны", "исследовано %d зон" },
    ["%d skins sampled"] = { "учтена %d шкура", "учтено %d шкуры", "учтено %d шкур" },
    ["%d more skins to %s"] = { "Еще %d шкура до %s", "Еще %d шкуры до %s", "Еще %d шкур до %s" },
    ["%d more materials · /tsl for details"] = { "Еще %d материал · подробности: /tsl", "Еще %d материала · подробности: /tsl", "Еще %d материалов · подробности: /tsl" },
}

local germanNouns = {
    skin = "Häutung", skins = "Häutungen", material = "Material", materials = "Materialien",
    entry = "Eintrag", entries = "Einträge", species = "Arten", zone = "Gebiet", zones = "Gebiete"
}

local ruNouns = {
    skin = { "шкура", "шкуры", "шкур" },
    skins = { "шкура", "шкуры", "шкур" },
    material = { "материал", "материала", "материалов" },
    materials = { "материал", "материала", "материалов" },
    entry = { "запись", "записи", "записей" },
    entries = { "запись", "записи", "записей" },
    species = { "вид", "вида", "видов" },
    zone = { "зона", "зоны", "зон" },
    zones = { "зона", "зоны", "зон" },
}

function S.Fmt(text, ...)
    local first, second = ...
    local loc = S.GetLocale()
    if loc == "ruRU" then
        if ruSingularFormats[text] then
            local forms = ruSingularFormats[text]
            local fmt = ruPlural(first, forms[1], forms[2], forms[3])
            return string.format(fmt, ...)
        end
        if text == "%s · %d species discovered" then
            local fmt = ruPlural(second, "%s · обнаружен %d вид", "%s · обнаружено %d вида", "%s · обнаружено %d видов")
            return string.format(fmt, ...)
        end
        if text == "%d skinned · %d materials" then
            local matFmt = ruPlural(second, "%d материал", "%d материала", "%d материалов")
            return string.format("%d освеж. · " .. matFmt, first, second)
        end
        return string.format(S.L(text), ...)
    elseif loc == "deDE" then
        local fmt = S.L(text)
        if first == 1 and singularFormats[text] then fmt = singularFormats[text][2] end
        if text == "%s · %d species discovered" and second == 1 then fmt = "%s · %d Art entdeckt" end
        if text == "%d skinned · %d materials" and second == 1 then fmt = "%d gehäutet · %d Material" end
        return string.format(fmt, ...)
    end
    local fmt = S.L(text)
    if first == 1 and singularFormats[text] then fmt = singularFormats[text][1] end
    if text == "%d skinned · %d materials" and second == 1 then fmt = "%d skinned · %d material" end
    return string.format(fmt, ...)
end

function S.N(n, singular, plural)
    local loc = S.GetLocale()
    if loc == "ruRU" then
        local forms = ruNouns[singular] or ruNouns[plural]
        if forms then
            return n .. " " .. ruPlural(n, forms[1], forms[2], forms[3])
        end
        return n .. " " .. (S.L(singular) or singular)
    elseif loc == "deDE" then
        local word = n == 1 and singular or (plural or singular .. "s")
        return n .. " " .. (germanNouns[word] or S.L(word))
    end
    return n .. " " .. (n == 1 and singular or (plural or singular .. "s"))
end

S.localeStrings = { ru = ru, de = de }

