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
local internal = RunDirectorGodPool_Internal

-- =============================================================================
-- FILL: Module definition
-- =============================================================================

public.definition = {
    modpack      = PACK_ID, -- Opts this module into pack discovery
    id           = "GodPool",
    name         = "God Pool",
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

public.store = nil
store = nil
internal.standaloneUi = nil

local function DrawSectionHeading(imgui, text)
    lib.widgets.text(imgui, text)
    lib.widgets.separator(imgui)
end

local COLORS = nil

function internal.DrawTab(imgui, uiState)
    DrawSectionHeading(imgui, "God Pool")
    
    lib.widgets.dropdown(imgui, uiState, "MaxGodsPerRun", {
        label = "Max Gods Per Run",
        values = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
        controlGap = 20,
        controlWidth = 60,
    })
    
    -- Explicit UI declarations for easy tweaking later
    lib.widgets.checkbox(imgui, uiState, "AphroditeEnabled",  { label = "Aphrodite",  color = COLORS.AphroditeEnabled })
    imgui.SameLine()    imgui.SetCursorPosX(150)
    lib.widgets.checkbox(imgui, uiState, "ApolloEnabled",     { label = "Apollo",     color = COLORS.ApolloEnabled })
    imgui.SameLine()    imgui.SetCursorPosX(300)
    lib.widgets.checkbox(imgui, uiState, "AresEnabled",       { label = "Ares",       color = COLORS.AresEnabled })
    lib.widgets.checkbox(imgui, uiState, "DemeterEnabled",    { label = "Demeter",    color = COLORS.DemeterEnabled })
    imgui.SameLine()    imgui.SetCursorPosX(150)
    lib.widgets.checkbox(imgui, uiState, "HephaestusEnabled", { label = "Hephaestus", color = COLORS.HephaestusEnabled })
    imgui.SameLine()    imgui.SetCursorPosX(300)
    lib.widgets.checkbox(imgui, uiState, "HeraEnabled",       { label = "Hera",       color = COLORS.HeraEnabled })
    lib.widgets.checkbox(imgui, uiState, "HestiaEnabled",     { label = "Hestia",     color = COLORS.HestiaEnabled })
    imgui.SameLine()    imgui.SetCursorPosX(150)
    lib.widgets.checkbox(imgui, uiState, "PoseidonEnabled",   { label = "Poseidon",   color = COLORS.PoseidonEnabled })
    imgui.SameLine()    imgui.SetCursorPosX(300)
    lib.widgets.checkbox(imgui, uiState, "ZeusEnabled",       { label = "Zeus",       color = COLORS.ZeusEnabled })

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
    public.DrawTab = internal.DrawTab
end

local function init()
    import_as_fallback(rom.game)
    import("mods/data.lua")
    public.store = lib.store.create(config, public.definition, dataDefaults)
    store = public.store
    COLORS = {
        AphroditeEnabled  = { game.Color.AphroditeDamage[1] / 255, game.Color.AphroditeDamage[2] / 255, game.Color.AphroditeDamage[3] / 255, game.Color.AphroditeDamage[4] / 255 },
        ApolloEnabled     = { game.Color.ApolloDamageLight[1] / 255, game.Color.ApolloDamageLight[2] / 255, game.Color.ApolloDamageLight[3] / 255, game.Color.ApolloDamageLight[4] / 255 },
        AresEnabled       = { game.Color.AresDamageLight[1] / 255, game.Color.AresDamageLight[2] / 255, game.Color.AresDamageLight[3] / 255, game.Color.AresDamageLight[4] / 255 },
        DemeterEnabled    = { game.Color.DemeterDamage[1] / 255, game.Color.DemeterDamage[2] / 255, game.Color.DemeterDamage[3] / 255, game.Color.DemeterDamage[4] / 255 },
        HephaestusEnabled = { game.Color.HephaestusDamage[1] / 255, game.Color.HephaestusDamage[2] / 255, game.Color.HephaestusDamage[3] / 255, game.Color.HephaestusDamage[4] / 255 },
        HeraEnabled       = { game.Color.HeraDamage[1] / 255, game.Color.HeraDamage[2] / 255, game.Color.HeraDamage[3] / 255, game.Color.HeraDamage[4] / 255 },
        HestiaEnabled     = { game.Color.HestiaDamageLight[1] / 255, game.Color.HestiaDamageLight[2] / 255, game.Color.HestiaDamageLight[3] / 255, game.Color.HestiaDamageLight[4] / 255 },
        PoseidonEnabled   = { game.Color.PoseidonDamage[1] / 255, game.Color.PoseidonDamage[2] / 255, game.Color.PoseidonDamage[3] / 255, game.Color.PoseidonDamage[4] / 255 },
        ZeusEnabled       = { game.Color.ZeusDamageLight[1] / 255, game.Color.ZeusDamageLight[2] / 255, game.Color.ZeusDamageLight[3] / 255, game.Color.ZeusDamageLight[4] / 255 },
    }
    registerHooks()
    if lib.coordinator.isEnabled(store, public.definition.modpack) then
        lib.mutation.apply(public.definition, store)
    end
    if public.definition.affectsRunData and not lib.coordinator.isCoordinated(public.definition.modpack) then
        SetupRunData()
    end
    internal.standaloneUi = lib.host.standaloneUI(
        public.definition,
        store,
        store.uiState,
        {
            drawTab = internal.DrawTab,
        }
    )
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

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_imgui(function()
    if internal.standaloneUi and internal.standaloneUi.renderWindow then
        internal.standaloneUi.renderWindow()
    end
end)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(function()
    if internal.standaloneUi and internal.standaloneUi.addMenuBar then
        internal.standaloneUi.addMenuBar()
    end
end)
