local DbOption = require('Options.DbOption')
local oms = require('optionsModsScripts')

local _ = i18n.ptranslate

local dialogRef = nil

local function update()
    if dialogRef ~= nil then
        local enabled = dialogRef.generalEnabledFighterToFighterDatalinkCheckbox:getState()
        dialogRef.networkNatsHostnameEditBox:setEnabled(enabled)
        dialogRef.networkNatsPortEditBox:setEnabled(enabled)
        dialogRef.networkNatsEnableSslCheckbox:setEnabled(enabled)
    end
end

local options = {
    generalEnabled = DbOption:new():setValue(true):checkbox(),
    generalEnabledScriptedEwr = DbOption:new():setValue(true):checkbox(),
    generalEnabledFighterToFighterDatalink = DbOption:new():setValue(true):checkbox():callback(function(value) update() end),
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