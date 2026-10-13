local DbOption = require('Options.DbOption')
local oms = require('optionsModsScripts')
local lfs = require('lfs')

local _ = i18n.ptranslate

local dialogRef = nil

-- used to install export hook
local function install_export_hook()
    local srcFile = assert(io.open(lfs.writedir()..[[Mods/tech/DataLink/Scripts/Hooks/DataLink.lua]], "rb"))
    local destFile = assert(io.open(lfs.writedir()..[[Scripts/Hooks/DataLink.lua]], "wb"))
    destFile:write(srcFile:read("*all"))
    srcFile:close()
    destFile:close()    
end

-- unloads package
local function unloadPackage(package_name)
  package[package_name] = nil
  package.loaded[package_name] = nil
  _G[package_name] = nil
end

-- require options
local Options = require('optionsEditor')

-- perform initial setup, or re-installation of hook if it is still configured in options
if  (Options.getOption("plugins.DataLink.generalEnabled") == nil or Options.getOption("plugins.DataLink.generalEnabled")) and not lfs.attributes(lfs.writedir()..[[Scripts/Hooks/DataLink.lua]]) then
    log.info("DataLink: installing export hook.")
    install_export_hook()
end
-- unload optionsEditor package
unloadPackage("optionsEditor")


local function update()
    if dialogRef ~= nil then
        local generalEnabled = dialogRef.generalEnabledCheckbox:getState()
        dialogRef.generalEnabledFighterToFighterDatalinkCheckbox:setEnabled(generalEnabled)
        dialogRef.generalEnabledScriptedEwrCheckbox:setEnabled(generalEnabled)
        local enabledFighterToFighterDatalink = dialogRef.generalEnabledFighterToFighterDatalinkCheckbox:getState() and generalEnabled
        dialogRef.networkNatsHostnameEditBox:setEnabled(enabledFighterToFighterDatalink)
        dialogRef.networkNatsPortEditBox:setEnabled(enabledFighterToFighterDatalink)
        dialogRef.networkNatsEnableSslCheckbox:setEnabled(enabledFighterToFighterDatalink)
        dialogRef.generalEnabledDebugCheckbox:setEnabled(generalEnabled)
        local enabledDebug = dialogRef.generalEnabledDebugCheckbox:getState() and generalEnabled
        local enabledDebugDummyTargets = dialogRef.generalEnabledDebugDummyTargetsCheckbox:getState() and enabledDebug
        dialogRef.generalEnabledDebugDummyTargetsCheckbox:setEnabled(enabledDebug)
        dialogRef.tacticalGroupIDEditBox:setEnabled(enabledFighterToFighterDatalink)
        dialogRef.tacticalGroupPositionSlider:setEnabled(enabledFighterToFighterDatalink)
    end
end

local function restartRequired(state)
    local message = nil
    if state then
        message = _("In order to enable the DataLink mod, you need to restart the game.")
        install_export_hook()
    else
        message = _("In order to disable the DataLink mod fully, you need to restart the game.")
        os.remove(lfs.writedir()..[[Scripts/Hooks/DataLink.lua]])
    end
    local handler = MsgWindow.question(message, _("APPLY CHANGES"), _('Restart Now'), _('Restart Later'))
    function handler:onChange(buttonText)
        if buttonText == _('Restart Now') then
            optionsEditor.setOption("plugins.DataLink.generalEnabled", state)
            restartME()
        end
    end
    handler:show()
end

local options = {
    generalEnabled = DbOption.new():setValue(true):checkbox():callback(
        function(value)
            log.info("DataLink: generalEnabled changed to: " .. tostring(value))
            update()
            restartRequired(value)
        end
    ),
    generalEnabledScriptedEwr = DbOption.new():setValue(true):checkbox(),
    generalEnabledFighterToFighterDatalink = DbOption.new():setValue(true):checkbox():callback(function(value) update() end),
    generalEnabledDebug = DbOption.new():setValue(false):checkbox():callback(function(value) update() end),
    generalEnabledDebugDummyTargets = DbOption.new():setValue(false):checkbox(),
    networkNatsHostname = DbOption.new():setValue("demo.nats.io"):editbox(),
    networkNatsPort = DbOption.new():setValue(4222):editbox(),
    networkNatsEnableSsl = DbOption.new():setValue(true):checkbox(),
    tacticalGroupID = DbOption.new():setValue(""):editbox(),
    tacticalGroupPosition = DbOption.new():setValue(1):slider(DbOption.Range(1, 4)),
    callbackOnShowDialog = function(dialog)
        if dialog ~= dialogRef then
           dialogRef = dialog
        end
        update()
    end,
}

log.info("DataLink: options loaded")
return options
