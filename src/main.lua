local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
local chalk = mods['SGG_Modding-Chalk']
local reload = mods['SGG_Modding-ReLoad']
lib = mods['adamant-ModpackLib']

local dataDefaults = import("config.lua")
local config = chalk.auto('config.lua')


local PACK_ID = "run-director"
RunDirectorGodPool_Internal = RunDirectorGodPool_Internal or {}

import("mods/data.lua")
local internal = RunDirectorGodPool_Internal

-- =============================================================================
-- FILL: Module definition
-- =============================================================================

public.definition = {
    modpack      = PACK_ID, -- Opts this module into pack discovery
    id           = "GodPool",
    name         = "God Pool",
    category     = "God Pool",
    tooltip      = "Control which gods enter the run, first-room hammer behavior, and pool support rules.",
    default      = dataDefaults.Enabled,
    affectsRunData = true, -- true if lifecycle changes require run-data rebuilds, false for hook-only mods
}

public.definition.storage = {
    { type = "int",    alias = "MaxGodsPerRun",                    configKey = "MaxGodsPerRun",                    min = 1, max = 9 },
    { type = "bool",   alias = "AphroditeEnabled",                 configKey = "AphroditeEnabled" },
    { type = "bool",   alias = "ApolloEnabled",                    configKey = "ApolloEnabled" },
    { type = "bool",   alias = "AresEnabled",                      configKey = "AresEnabled" },
    { type = "bool",   alias = "DemeterEnabled",                   configKey = "DemeterEnabled" },
    { type = "bool",   alias = "HephaestusEnabled",                configKey = "HephaestusEnabled" },
    { type = "bool",   alias = "HeraEnabled",                      configKey = "HeraEnabled" },
    { type = "bool",   alias = "HestiaEnabled",                    configKey = "HestiaEnabled" },
    { type = "bool",   alias = "PoseidonEnabled",                  configKey = "PoseidonEnabled" },
    { type = "bool",   alias = "ZeusEnabled",                      configKey = "ZeusEnabled" },
    { type = "bool",   alias = "KeepsakeAddsGod",                  configKey = "KeepsakeAddsGod" },
    { type = "bool",   alias = "PreventEarlySeleneHermes",         configKey = "PreventEarlySeleneHermes" },
    { type = "bool",   alias = "BoostElementGathering",            configKey = "BoostElementGathering" },
    { type = "bool",   alias = "PrioritizeHammerFirstRoomEnabled", configKey = "PrioritizeHammerFirstRoomEnabled" },
}

-- =============================================================================
-- FILL: apply() — mutate game data (use backup before changes)
-- =============================================================================

public.definition.patchPlan = function(plan)
    if internal.BuildPatchPlan then
        internal.BuildPatchPlan(plan)
    end
end

public.store = lib.store.create(config, public.definition, dataDefaults)
store = public.store

local function DrawSectionHeading(imgui, text)
    lib.widgets.text(imgui, text)
    lib.widgets.separator(imgui)
end

function internal.DrawTab(imgui, uiState)
    DrawSectionHeading(imgui, "God Pool")
    lib.widgets.dropdown(imgui, uiState, "MaxGodsPerRun", {
        label = "Max Gods Per Run",
        values = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
        controlGap = 20,
        controlWidth = 60,
    })
    lib.widgets.checkbox(imgui, uiState, "AphroditeEnabled", { label = "Aphrodite" })
    lib.widgets.checkbox(imgui, uiState, "ApolloEnabled", { label = "Apollo" })
    lib.widgets.checkbox(imgui, uiState, "AresEnabled", { label = "Ares" })
    lib.widgets.checkbox(imgui, uiState, "DemeterEnabled", { label = "Demeter" })
    lib.widgets.checkbox(imgui, uiState, "HephaestusEnabled", { label = "Hephaestus" })
    lib.widgets.checkbox(imgui, uiState, "HeraEnabled", { label = "Hera" })
    lib.widgets.checkbox(imgui, uiState, "HestiaEnabled", { label = "Hestia" })
    lib.widgets.checkbox(imgui, uiState, "PoseidonEnabled", { label = "Poseidon" })
    lib.widgets.checkbox(imgui, uiState, "ZeusEnabled", { label = "Zeus" })

    imgui.Spacing()
    DrawSectionHeading(imgui, "Options")
    lib.widgets.checkbox(imgui, uiState, "KeepsakeAddsGod", {
        label = "God Keepsakes Add to The Pool",
    })
    lib.widgets.checkbox(imgui, uiState, "PreventEarlySeleneHermes", {
        label = "Prevent Early Selene/Hermes",
    })
    lib.widgets.checkbox(imgui, uiState, "BoostElementGathering", {
        label = "Guarantee Element from Gathering Tool",
    })
    lib.widgets.checkbox(imgui, uiState, "PrioritizeHammerFirstRoomEnabled", {
        label = "Force Hammer First Room",
    })
end

-- =============================================================================
-- FILL: registerHooks() — wrap game functions
-- =============================================================================

local function registerHooks()
    import("mods/logic.lua")
    if internal.RegisterHooks then
        internal.RegisterHooks()
    end
end

local function init()
    import_as_fallback(rom.game)
    registerHooks()
    if lib.coordinator.isEnabled(store, public.definition.modpack) then
        lib.mutation.apply(public.definition, store)
    end
    if public.definition.affectsRunData and not lib.coordinator.isCoordinated(public.definition.modpack) then
        SetupRunData()
    end
end

-- =============================================================================
-- Wiring (do not modify)
-- =============================================================================

public.isGodEnabledInPool = function(godKey)
    if internal.IsGodEnabledInPool then
        return internal.IsGodEnabledInPool(godKey)
    end
    return true
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(init, init)
end)

local standaloneUi = lib.special.standaloneUI(
    public.definition,
    store,
    store.uiState,
    {
        drawTab = internal.DrawTab,
    }
)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_imgui(standaloneUi.renderWindow)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(standaloneUi.addMenuBar)
