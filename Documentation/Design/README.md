# Data Link Design
## System high level overview

DataLink mod hs the following goals:
- Recreate DCS flanker fighter-to-fighter datalink for multiplayer games. It is worth nothing that current single player implementation provided by ED, is not exactly following the original to the full extent. Namely missing is the command interface as well as designation of targets.
- Maintain **integrity check** compliance without modifying the core modules or DCS installation.
- Ensure that all source code and building procedures can be reviewed by third parties.
- Extensible in terms of server support for provoding alternative data source by server owners.
- Support ability for server owners to disallow the usage of the mod. Namely scripted EWR scripts will be added on opt-in basis, while the export of radar is already controlled via built-in DCS server feature to disable sensor exports. For more information please check ED DCS server documentation.

The following diagram repsresent the high level overview involving:
- 2 DCS clients
- 1 DCS server
- 1 NATS server (DataLink comminication relay)

![High level overview](High_Level_Diagram.png)

The DCS client consist of basic DCS installation with compatible modules and 2 lua environments:
- Hook Export Environment
- Cockpit Environment

### Functions of Export Environment

- Implements contact data sources.
- Facilitates communication with communication relay (NATS server) through NATS publish/subscribe/callback interface.
- Correlates and resolves received contacts from multiple contact data sources.
- Removes expired contacts
- Feeds the cockpit indicators for user interaction.

Presently supported data sources:
- Radar source (as controlled by sensor export server setting). No export -> no enemy contacts.
- Scipted EWR (at the moment empty placeholder), can be implemented for servers choosing to opt in, provided that they have some sort off output to players already.

### Functions of Cockpit Environment

- Decoding of received device commands
- Display of received contacts on HDD (or better said on the overlay above)
- Update of contacts
- Removal of expired from HDD

It should be noted that it does not interact with real HDD.

### NATS server (communication relay)

NATS server provides communication medium between clients where each of them acts as:
- donor of contacts,
- receives the contacts from other donors.

NATS server is off-the-shelf server software which can be executed anywhere:
- on your local PC,
- on the squadron server,
- or on DCS server hosting multiplayer session.

Additional flexibility is that each squadron can have own server in which case their movement and contacts remain private from other players. Important to note is that mod can be configured with only one server at the time.

Presently configured server is not meant for production use and is not provided by this project. It should not be used for extensive periods of time: it is there just to demonstrate the NATS protocol.

NATS server provodes following primitives:
- subscription to topics
- publishing to topics
- topic notifications through callbacks of received messages.

Furter reading on NATS server and download: [https://github.com/nats-io/nats-server](https://github.com/nats-io/nats-server)

### DCS Server

This is good-old DCS server as provided by ED and customized by server owners. 
In case of interest of server to directly provide interface (and thus control what DataLink displays to clients), additional help can be provided to server owner/developer.
