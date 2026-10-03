local DbOption = require('Options.DbOption')
local oms = require('optionsModsScripts')

local _ = i18n.ptranslate

local dialogRef = nil

local function update()
    if dialogRef ~= nil then
        local generalEnabled = dialogRef.generalEnabledCheckbox:getState()
        dialogRef.generalEnabledFighterToFighterDatalinkCheckbox:setEnabled(generalEnabled)
        dialogRef.generalEnabledScriptedEwrCheckbox:setEnabled(generalEnabled)
        local enabledFighterToFighterDatalink = dialogRef.generalEnabledFighterToFighterDatalinkCheckbox:getState() and generalEnabled
        dialogRef.networkNatsHostnameEditBox:setEnabled(enabledFighterToFighterDatalink)
        dialogRef.networkNatsPortEditBox:setEnabled(enabledFighterToFighterDatalink)
        dialogRef.networkNatsEnableSslCheckbox:setEnabled(enabledFighterToFighterDatalink)
    end
end

local options = {
    generalEnabled = DbOption:new():setValue(true):checkbox():callback(function(value) update() end),
    generalEnabledScriptedEwr = DbOption:new():setValue(true):checkbox(),
    generalEnabledFighterToFighterDatalink = DbOption:new():setValue(true):checkbox():callback(function(value) update() end),
    generalEnabledDebug = DbOption:new():setValue(false):checkbox(),
    networkNatsHostname = DbOption:new():setValue("demo.nats.io"):editbox(),
    networkNatsPort = DbOption:new():setValue(4222):editbox(),
    networkNatsEnableSsl = DbOption:new():setValue(true):checkbox(),
    callbackOnShowDialog = function(dialog)
        if dialog ~= dialogRef then
           dialogRef = dialog
        end
        update()
    end,
}

return options
