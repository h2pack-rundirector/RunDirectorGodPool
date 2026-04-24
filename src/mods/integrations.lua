local internal = RunDirectorGodPool_Internal

local GOD_AVAILABILITY_INTEGRATION = "run-director.god-availability"

function internal.RegisterIntegrations()
    lib.integrations.register(GOD_AVAILABILITY_INTEGRATION, internal.definition.id, {
        isActive = function()
            return lib.isModuleEnabled(internal.store, internal.definition.modpack)
        end,

        isAvailable = function(godKey)
            if not lib.isModuleEnabled(internal.store, internal.definition.modpack) then
                return true
            end
            if internal.IsGodEnabledInPool then
                return internal.IsGodEnabledInPool(godKey) ~= false
            end
            return true
        end,
    })
end

return internal
