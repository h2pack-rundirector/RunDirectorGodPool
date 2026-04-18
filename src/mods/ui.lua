local internal = RunDirectorGodPool_Internal

local COLORS = nil

local function DrawSectionHeading(imgui, text)
    lib.widgets.text(imgui, text)
    lib.widgets.separator(imgui)
end

function internal.SetUiColors(colors)
    COLORS = colors
end

function internal.ResetAllControls(uiState)
    if not uiState then
        return false
    end

    local changed = false
    for _, node in ipairs(lib.storage.getRoots(public.definition.storage) or {}) do
        local current = uiState.view and uiState.view[node.alias] or nil
        if not lib.storage.valuesEqual(node, current, node.default) then
            uiState.reset(node.alias)
            changed = true
        end
    end

    return changed
end

function internal.DrawTab(imgui, uiState)
    DrawSectionHeading(imgui, "God Pool")

    lib.widgets.dropdown(imgui, uiState, "MaxGodsPerRun", {
        label = "Max Gods Per Run",
        values = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
        controlGap = 20,
        controlWidth = 60,
    })

    lib.widgets.checkbox(imgui, uiState, "AphroditeEnabled",  { label = "Aphrodite",  color = COLORS.AphroditeEnabled })
    imgui.SameLine() imgui.SetCursorPosX(150)
    lib.widgets.checkbox(imgui, uiState, "ApolloEnabled",     { label = "Apollo",     color = COLORS.ApolloEnabled })
    imgui.SameLine() imgui.SetCursorPosX(300)
    lib.widgets.checkbox(imgui, uiState, "AresEnabled",       { label = "Ares",       color = COLORS.AresEnabled })
    lib.widgets.checkbox(imgui, uiState, "DemeterEnabled",    { label = "Demeter",    color = COLORS.DemeterEnabled })
    imgui.SameLine() imgui.SetCursorPosX(150)
    lib.widgets.checkbox(imgui, uiState, "HephaestusEnabled", { label = "Hephaestus", color = COLORS.HephaestusEnabled })
    imgui.SameLine() imgui.SetCursorPosX(300)
    lib.widgets.checkbox(imgui, uiState, "HeraEnabled",       { label = "Hera",       color = COLORS.HeraEnabled })
    lib.widgets.checkbox(imgui, uiState, "HestiaEnabled",     { label = "Hestia",     color = COLORS.HestiaEnabled })
    imgui.SameLine() imgui.SetCursorPosX(150)
    lib.widgets.checkbox(imgui, uiState, "PoseidonEnabled",   { label = "Poseidon",   color = COLORS.PoseidonEnabled })
    imgui.SameLine() imgui.SetCursorPosX(300)
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

function internal.DrawQuickContent(imgui, uiState)
    lib.widgets.checkbox(imgui, uiState, "PrioritizeHammerFirstRoomEnabled", {
        label = "Force Hammer First Room",
    })

    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetCursorPosX() + 50)

    lib.widgets.confirmButton(imgui, "god_pool_quick_reset_all", "Reset All", {
        confirmLabel = "Confirm Reset All",
        onConfirm = function()
            internal.ResetAllControls(uiState)
        end,
    })
end
