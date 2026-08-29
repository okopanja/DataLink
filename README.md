# DataLink Overlay

A DCS World mod that adds a configurable datalink for Flanker aircraft cockpits.

## Description

DataLink Overlay is a cockpit modification that displays a customizable overlay positioned over the centre display in supported aircraft. The overlay provides enhanced datalink information presentation directly in your cockpit view.

### Features

- Scripted EWR as data source
- Seamless integration with DCS World cockpit systems

### Supported Aircraft

- **Su-27 Flanker-B**
- **Su-33 Flanker-D**
- **J-11A**

## Installation

### Requirements

- DCS World (Stable or Open Beta)
- One or more of the supported aircraft modules

### Installation Steps

1. **Locate your DCS Saved Games folder:**
   - Default location: `C:\Users\[YourUsername]\Saved Games\DCS\`

2. **Copy the mod files:**
   - Copy all files from repository to:
     ```
     %USERPROFILE%\Saved Games\DCS\Mods\tech\DataLink
     ```
   - Copy the hook file Scripts\Hooks\DataLink.lua to:
     ```
     %USERPROFILE%\Saved Games\DCS\Scripts\Hooks
     ```
3. **Verify installation:**
   - Launch DCS World
   - Start a mission with a supported aircraft (Su-27, Su-33, or J-11A)
   - The datalink overlay should be visible on the centre display

## De-installation

To remove the DataLink Overlay mod:

1. **Navigate to your DCS Mods folder:**
   ```
   %USERPROFILE%\Saved Games\DCS\Mods\tech\
   ```

2. **Delete the DataLink folder:**
   - Delete the entire `DataLink` folder and all its contents
     
3. **Navigate to your DCS Scripts folder:**
   ```
   %USERPROFILE%\Saved Games\DCS\Scripts\Hooks
   ```

4. **Delete the hook file:**
   - Delete the 'DataLink.lua'

5. **Verify removal:**
   - Launch DCS World
   - The overlay should no longer appear in supported aircraft

## Frequently asked question

1. Does this mod break IC (Integrity Check)?

No

2. Is this MOD a cheat?

No, it was not designed to be a cheat, however you should respect the rules of the server you connect to. If you get asked not to use this MOD, do not use it.

3. How are information on aircrafts retreived?

MOD supports implementation of different Contact Sources. Per default it is supplied with Scripted EWR Contact Source, which relies on information the server owners are willing to broadcast. However in future additional data sources will be added.

4. Do I need DCS FC3/FC4 modules?

Yes it works only as addon on for existing Flanker modules.

## Developer

Created by: **okopanja**  
GitHub: [https://github.com/okopanja](https://github.com/okopanja)

## Contributing

Contributions, bug reports, and feature requests are welcome! Please visit the GitHub repository for more information.

---

*This mod is not affiliated with or endorsed by Eagle Dynamics or any aircraft manufacturers.*
