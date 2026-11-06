THE SKINNING LOG
By Serron
Leather-patterned progress | Version 0.4.3 | WoW Forever / Interface 16001

QUICK START

After updating the existing addon, /reload. On first use, the welcome window
introduces the journal, tracker, goals and research XP. Existing journals
keep their setup; /tsl help opens the instructions again.

Skin a creature and collect the skinning loot. The journal records the
creature, materials, and your position automatically. Normal corpse loot
is excluded. Earlier discoveries, notes, favorites, goals, and preferences
from 0.1.0 are retained. Existing recorded history receives XP credit
once, using the same skin/discovery/zone/mastery rules as new observations.

The addon is installed as the-skinning-log-sol. Its own saved variable is
SkinningLogSolDB. It does not alter another skinning addon or its data.
The internal folder and saved-variable identifier remain stable to retain
existing journals. The public name is now simply The Skinning Log.

COMMANDS

/tsl                 Toggle the journal
/tsl help            Welcome, instructions, XP rules, sample and preview
/tsl tracker         Show or hide the compact live tracker
/tsl here            Open WoW's actual world map in your current area
/tsl materials       Material sources, estimates and collection goals
/tsl session         Current expedition and completed session history
/tsl research        Research ranks, titles, badges and next fieldwork
/tsl new             Archive the expedition and start a fresh one
/tsl config          Preferences, scaling and position reset
/tsl demo            Toggle a separate fictional sample journal
/tsl export          Copy the creature summary as CSV
/skinninglog, /slsol, /skinningsol   Existing command aliases remain available

The minimap journal icon opens the journal on left click and the world
map on right click. Drag the icon to reposition it. If an updated AddOns
list icon is cached by the client, restart the game to refresh metadata.

WHAT CHANGED IN 0.4.3

- Progress detail uses the actual Leatherworking profession atlas, rather than
  the generic DefaultBlue bevel. The leather pattern keeps its contrast with
  normal blending and is tinted blue, gold or green. Missing leather artwork
  falls back to DefaultBlue, then to the shaded base if neither is available.
- Heading alignment and bar spacing from 0.4.2 are retained. Saved data is unchanged.

WHAT CHANGED IN 0.4.2

- Progress bars have a shaded, opaque color fill under additive profession
  artwork. Dark pixels in the artwork no longer obscure earned progress.
  The detail uses the native flipbook's settled frame, without idle animation.
- Taller blue research, gold mastery/skill and green goal fills are readable
  in the journal and tracker. Empty values remain empty and full fills stay
  within their bronze frames. Missing native detail retains a shaded fill.
- Decorative heading end caps retain their native width. Localized headings
  are centered vertically and inset inside the border across all pages,
  discovery cards and the tracker. Material column labels share the alignment.
- Existing observations, settings, saved positions and the sidebar are retained.

WHAT CHANGED IN 0.4.1

- Creature tooltips show sample size, explicitly labeled average materials per
  skin, and up to three material icons with total quantity and observed rate.
  The rate is the share of sampled skins containing that material, rather
  than its share of all collected items. Small samples below ten are marked.
- Shows the current data scope, your character's species mastery, relevant
  collection goal progress and a saved field note. Personal mastery remains
  character-specific even when viewing all-character drop statistics.
- Live creature tooltips always use recorded data, including when browsing
  the separate fictional sample journal. Native tooltip content is preserved.
- Adds no custom tooltip frames, polling or price lookups. Tooltip hooks are
  registered once, and a block is appended only once until the tooltip clears.

WHAT CHANGED IN 0.4.0

- The six journal sections use the actual Forever Legacy sidebar artwork:
  bronze framed cards, circular icons, rings, gold selection glow and divider.
  Hover an icon for its section name; the current section has a visible heading.
  Our own controls reference native atlases without loading the Legacy talent UI.
- The content keeps its existing size. The journal adds space for the sidebar
  and automatically fits the screen. Saved positions, dragging and scale remain.
  If a client lacks any required sidebar atlas, aligned top tabs remain available.
- XP, mastery, collection and profession bars use taller framed native profession
  artwork, tinted blue, gold or green. The header XP label is centered in its bar.
  A fixed-size fill is revealed with a mask so its pattern does not stretch as
  progress changes. Empty bars hide the fill; completed goals clamp at full.
- The decorative fill uses one still from the native flipbook. It adds no
  continuous animation, timer, event subscription or per-update frame allocation.
- The compact tracker remains 292 units wide: 127 high without a goal, 165 with
  a goal; expansion adds 151. Existing progress and preferences are retained.

Native asset references:
https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_LegacySystem/Blizzard_LegacyTree.xml
https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProfessionsBook/Camelot/Blizzard_ProfessionsBookTemplates.xml
https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProfessionsTemplates/Blizzard_ProfessionsRankBar.lua
Native textures are loaded from the client and are not bundled in this addon.

WHAT CHANGED IN 0.3.1

- /tsl is now the primary command, including all existing subcommands.
  /skinninglog, /slsol and /skinningsol remain available as aliases.
- Updated in-game command hints and metadata to use /tsl.

WHAT CHANGED IN 0.3.0

- Compact loot text after every recorded skin: material icon, collected
  quantity, item link and creature name. Discovery cards continue as before.
  Normal corpse loot and duplicate events produce no skinning notification.
  Reopened partial skin loot announces only the newly collected materials.
- Up to three short-lived text lines, using a fixed reusable display. It
  passes mouse input through to the game, adds no per-loot expiry timers,
  and removes its update script when idle. Preferences > Skin loot
  notifications toggles it independently of discovery cards.
- The title bar and the journal header can both be dragged, above the native
  decorative frame layers. The close button is kept clear. Position is saved.
- Removed SOL from visible titles, tooltips, map controls and chat prefixes.
  Added /skinninglog, with /slsol and /skinningsol retained as aliases.
- Optional minimap gathering pins reuse one zone's clusters until observations,
  filters or zone change. Released world pins clear their observation reference.
- Player spell events use native unit filters when supported. Locale and
  family lookup tables are shared rather than reconstructed on each call.
- Exceptional journal construction allows one retry. After two failed builds,
  /reload is required so repeated clicks cannot accumulate failed frame trees.
- Creature-list tooltips explain skin totals, material totals and average yield.
  The German Weitschreiter family now uses its strider icon.
- Existing progression, goals, notes, favorites and preferences are preserved.

WHAT CHANGED IN 0.2.2

- Journal tabs now construct their own regions from native WoW tab textures.
  They no longer invoke TabButtonTemplate or depend on its child field names
  and initialization scripts, which differ between client builds.
- The journal stays hidden during construction and becomes the active window
  only once all controls are created. A failed construction can be retried.
- Static widget creation restores its collection state even when interrupted
  by an error; the error is still reported rather than silently discarded.
- World map pins, minimap launcher, tracker and saved progression are unchanged.

WHAT CHANGED IN 0.2.1

- Reworked world pin artwork: an explicitly registered native pin level,
  a separate child artwork frame, a visible gold rim, and visibility reset
  on reuse/zoom. Unavailable icon textures fall back to the addon icon.
- A circular minimap launcher using the native portrait mask and tracking
  border, with the same journal/map clicks and drag positioning.
- The journal now uses the client's PortraitFrameTemplate, including its
  round portrait, bronze title bar, borders and close button. Native shaped
  tabs and raised action buttons replace the flat rectangular controls.
- Native marble inset panels, rock background, textured section headings,
  warm borders, gold selection highlights and framed skill-style bars.
- Explicit opaque underlays prevent the world showing through the journal,
  detail cards, tracker and discovery notices. The tracker stays compact.
- No progress reset or additional XP migration. Reload to load the update;
  Help remains available without repeating the welcome automatically.

WHAT CHANGED IN 0.2.0

- A compact WoW-style tabbed journal with native borders, warm gold
  accents, clear controls, real dropdown menus and English/German labels.
- A valid IconTexture entry in the AddOns list.
- First-use instructions and an accessible Help window with a discovery
  preview and a separate XP explanation.
- An optional 292-wide live tracker: 121 UI units high without a goal,
  155 with a goal. It shows session totals, elapsed time, newest material,
  rate and research progress. Expand for profession skill, three recent
  gathers and shortcuts. Drag it freely; visibility, expansion, position
  and scale are saved.
- Creature entries show a larger model or a family emblem, level range,
  mastery, yields, estimated value and a summary of collected drops.
  "Observed drops" opens a richer, content-sized detail sheet with drop
  frequencies, sample size, notes and map actions. Long names wrap.
- Native item tooltips and item-quality colors where the game supplies
  that information.
- World map integration through a SOL-owned native map canvas provider.
  Material icons mark clustered recorded positions. Hover for species,
  materials and recent visit information; click for area details; right
  click for a waypoint. Zoom re-clusters pins. The map controls toggle
  SOL pins or clear a creature/material filter.
- Optional nearby gathering pins on the minimap, disabled by default.
- Material search, ranked observed sources, sample sizes, and goals that
  count newly collected materials on the character that created them.
- Visible archived expedition summaries, including earned XP for new
  sessions. Old sessions show no XP figure when none was recorded.
- An eight-rank research system, selectable journal titles, eight
  observation-based badges, and a suggested next creature milestone.
- Queued discovery, rank, mastery and goal notifications. Creature
  discoveries use a model or creature-family emblem. Notifications can
  be clicked; motion and sound are separately configurable. Sound is off
  by default.

RESEARCH XP

Research belongs to each character. The journal's all-character data
scope does not combine character XP or profession skill.

Successful skinning with collected loot:                     5 XP
First recorded species on that character:                  +40 XP
First recorded mapped zone on that character:              +25 XP
Species mastery at 10 / 50 / 100 skins:           +30 / 75 / 150 XP
Completed collection goal of at least 25 materials:         +25 XP

Goal XP is limited to two qualifying completions per character per local
calendar day. Goals below 25 remain usable but award no goal XP. Goals
only count loot gathered AFTER the goal was set. Reopening the same loot
window adds remaining collected materials without granting another skin
or research reward. Each mastery threshold is rewarded once per species.

Ranks (cumulative XP):
0       Field Apprentice
250     Pelt Tracker
800     Trailfinder
1800    Beast Researcher
3500    Seasoned Skinner
6500    Master Naturalist
11000   Keeper of the Wilds
18000   Living Atlas

Earned ranks unlock selectable titles inside the journal and tracker.
Badges recognize species collection, exploration, repeated skinning, and
creature mastery. These are addon achievements. Research XP never changes
your character level, profession skill, equipment, abilities, or gold.

UPGRADE CREDIT

On first loading 0.2.0, each existing character's SOL observations receive:
5 x recorded skins + 40 x discovered species + 25 x known mapped zones,
plus every 10/50/100 mastery milestone already reached by each species.
The resulting state is saved and not recalculated on subsequent loads.
Prior goal completions cannot be reconstructed and receive no retroactive
bonus. No live skinning record or discovery is fabricated by migration.

CONTROLS AND SCOPES

The journal has Creatures, Materials, Hunting Grounds, Expedition,
Research and Preferences tabs. Creatures, materials and hunting grounds
can show all characters or this character. Expeditions and research show
the current character. Favorites and notes are shared across characters.

Use the bottom +/- buttons or Preferences to scale the journal. Drag its
header to move it. Escape closes the journal, menus and detail windows.
The tracker has an expand button and a hide button. /tsl tracker brings
it back. Preferences can reset journal and tracker positions.

The creature list searches names, materials, zones and NPC IDs. Its menus
filter favorites/mastered species and sort total materials, yield per
skin, skin count, recency or name. Material search is separate.

MAPS AND WAYPOINTS

The Hunting Grounds tab lists recorded areas and opens the actual world
map. "Show on map" from a creature or material applies its filter. The
native map's SOL filter button clears that filter. Pins obey the chosen
character data scope. Up to 120 clusters are displayed at once to keep
the map readable; the journal retains the underlying aggregate data.

TomTom waypoints are used when installed. If the client supports native
user waypoints they are used next; otherwise coordinates are printed.
TomTom and Auctionator are optional, not required for tracking.

Minimap gathering pins are opt-in. They update once per second while
enabled and use the map's world-distance scale. Disable them if another
minimap replacement presents them poorly. The journal icon is controlled
separately from gathering pins.

DATA HONESTY AND KNOWN LIMITS

- This is an observation-based index, not a complete WoW Forever spawn
  catalogue. It reports discovered species without inventing a global
  completion denominator. The beta world can contain additional mobs.
- Positions are where YOU stood at the cast, aggregated into 2% map
  cells, not measured corpse positions or verified spawn points.
- Creature filters use per-creature material information for new map
  samples. Older 0.1.0 cells did not store that cross-reference; filtered
  legacy pins can omit a material breakdown rather than guess it.
- Material-filtered map pins show the target material quantity and the
  area's recorded skin sample. That does not claim every creature in the
  area supplied that item.
- Collected-drop frequency is an observed fraction of recorded skins,
  not a guaranteed server drop rate. Small samples vary.
- Area rankings measure collected quantities, not time-normalized farm
  efficiency. No automated farming, movement or harvesting is performed.
- Values use local Auctionator prices when available, then vendor prices,
  then zero if unknown. Estimates can be stale and are not sale proceeds.
- Partial loot reopening is recovered for up to 60 seconds while the
  same skinning context is available and the client supplies matching
  source GUIDs. Collect remaining loot before another cast or reload.
- A bounded one-day corpse GUID cache prevents repeated delivery from
  double-counting skins. No loot-source metadata means initial capture
  falls back to the cast target; reopening requires source confirmation.
- Lifetime aggregate totals persist. Detailed histories retain the 100
  latest records per data scope/session. The latest 20 completed session
  summaries are retained across characters.
- Session rates include travel and idle time since the first skin. They
  appear after one minute. Reloading or logging out archives the session.
- Creature models depend on NPC data available to the game. A family
  emblem remains visible until a model loads.
- Interface labels support German and English. Other client locales use
  English labels with the game's own localized creature/item/zone names.
- CSV column names remain English for a stable interchange schema.

SAMPLE JOURNAL

The sample journal and its research progress are fictional and kept out
of saved player data. Favorites, notes, titles and collection goals cannot
be saved from the sample. Actual skinning still logs to real data while
the sample is open. Native map filters identify sample mode.
Use /tsl demo again or Preferences > Exit sample to return to real data.

VALIDATION

73 deterministic tracking, migration, progression, map API fixture and UI
state checks pass, along with Lua 5.1 syntax checks. A separate first-open
test covers all six sections and recovery from interrupted construction.
Separate missing-art and missing-atlas-API fixtures verify usable fallback
navigation. A
stress fixture checks 10,030 commits, 240 warmed journal page visits,
30 session changes, 1,000 observed targets and 200 queued notices.
These tests verify bounded retained structures and frame reuse; they do
not measure the live client's memory, CPU time or frame rate. Layout
states were rendered from Lua frame data for visual inspection with
placeholder native textures/models. These checks do not replace a live
gameplay test of client event timing, native art or model loading.

Suggested first test:
1. /reload and open /tsl. Drag the title bar and the header beneath it.
2. Use the discovery preview; inspect and move the compact tracker.
3. Skin one creature and collect its loot. Confirm one skin and the XP.
4. Click the discovery, inspect its drops, then Show on map and hover a pin.
5. Set a material goal and check its progress in the tracker.
6. /reload and confirm that discoveries, XP, notes and settings persist.

Original implementation inspired by the collecting spirit of The Fishing
Log: https://www.curseforge.com/wow/addons/the-fishing-log
No Fishing Log or competing skinning addon source/assets are distributed.

