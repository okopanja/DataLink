# Server Owner Instructions

## Controling the usage of this mod on server

Since the mod passes the built-in Integrity Check it is imporant to emphasise that **server owners still have the means to disable the mod** on their servers.

Mod utilizes export function providing 2 kind of information:
- own position
- radar sensor information.

These export functions can be controlled by turning off options under **Server advanced settings**:
- Allow sensor export (set to off to disable radar contacts)
- Allow player export (set to off to disable own positions)

![Server advanced settings](Sever_Advanced_Settings.png)

On the client side the changes to these options will disable possibility for mod to receive the corresponding information from DCS.
In turn they will not be able to transmit to other players.

This ensures that mod users can still have mod installed and remain compliant with the server settings.

Additionally mod verifies early status of server export configuration and ensures that RPC communication with the server does not produce additional traffic by not calling export functions.
This way server is protected from excessive communication since mod does not invoke disabled export methods.

If you host the server directly from your own DCS client, you should be aware the of the DCS bug, causing your own ownship to keep sending your own position (but no radar picture). **This is not a bug in the mod, but rather DCS itself.**
Even in this case remaining connected clients will remain dormant (for them the configuration is correctly reported) and will not receive and display such updates.

## Providing custom data source by the server itself

Server owners desiring to provide custom radar picture to the mod users will be able to do so in the future. At this moment the specification is not yet complete.
Once the mod functionality is implemented the reference simplistic EWR data source shall be provided.

For high level description please see:  [Documentation/Design/README.md](Documentation/Design/README.md).