local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
local chalk = mods['SGG_Modding-Chalk']
local reload = mods['SGG_Modding-ReLoad']
---@type AdamantModpackLib
lib = mods['adamant-ModpackLib']

local dataDefaults = import("config.lua")
local config = chalk.auto('config.lua')

local PACK_ID = "run-director"
---@class RunDirectorGodPoolInternal
---@field definition ModuleDefinition|nil
---@field store ManagedStore|nil
---@field standaloneUi StandaloneRuntime|nil
---@field RegisterHooks fun()|nil
---@field DrawTab fun(imgui: table, session: AuthorSession)|nil
---@field DrawQuickContent fun(imgui: table, session: AuthorSession)|nil
---@field IsGodEnabledInPool fun(godKey: string): boolean|nil
RunDirectorGodPool_Internal = RunDirectorGodPool_Internal or {}
---@type RunDirectorGodPoolInternal
local internal = RunDirectorGodPool_Internal

public.definition = {
    modpack = PACK_ID,
    id = "GodPool",
    name = "God Pool",
    tooltip = "Control which gods enter the run, first-room hammer behavior, and pool support rules.",
    default = dataDefaults.Enabled,
    affectsRunData = true,
}
internal.definition = public.definition

public.host = nil
local store
local session
internal.standaloneUi = nil

local function init()
    import_as_fallback(rom.game)
    import("mods/data.lua")
    import("mods/logic.lua")
    import("mods/ui.lua")

    store, session = lib.createStore(config, internal.definition, dataDefaults)
    internal.store = store

    public.host = lib.createModuleHost({
        definition = internal.definition,
        store = store,
        session = session,
        hookOwner = internal,
        registerHooks = internal.RegisterHooks,
        drawTab = internal.DrawTab,
        drawQuickContent = internal.DrawQuickContent,
    })
    internal.standaloneUi = lib.standaloneHost(public.host)
end

public.isGodEnabledInPool = function(godKey)
    if internal.IsGodEnabledInPool then
        return internal.IsGodEnabledInPool(godKey)
    end
    return true
end

public.getBoonBansFilterState = function(godKey)
    local filteringActive = lib.isModuleEnabled(internal.store, internal.definition.modpack)
    if not filteringActive then
        return false, true
    end

    if internal.IsGodEnabledInPool then
        return true, internal.IsGodEnabledInPool(godKey)
    end

    return true, true
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(nil, init)
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
