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
        dialogRef.generalEnabledDebugCheckbox:setEnabled(generalEnabled)
        dialogRef.tacticalGroupIDEditBox:setEnabled(enabledFighterToFighterDatalink)
        dialogRef.tacticalGroupPositionSlider:setEnabled(enabledFighterToFighterDatalink)
    end
end

local function restartRequired(state)
    local message = nil
    if state then
        message = _("In order to enable the DataLink mod, you need to restart the game.")
    else
        message = _("In order to disable the DataLink mod fully, you need to restart the game.")
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
            update()
            restartRequired(value)
        end
    ),
    generalEnabledScriptedEwr = DbOption.new():setValue(true):checkbox(),
    generalEnabledFighterToFighterDatalink = DbOption.new():setValue(true):checkbox():callback(function(value) update() end),
    generalEnabledDebug = DbOption.new():setValue(false):checkbox(),
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

return options
