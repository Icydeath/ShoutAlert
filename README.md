# ShoutAlert
FFXI addon - Add various words to alert on found in shouts. Plays a sound when a match is found.

Commands

**Alerting on text in shout**
- //sa [add|remove] [StringToAlertOn] - adds or removes the alert text from the list
 
**Ignoring specific player shouts**

- //sa [ignore|i] [add|remove] [PlayerName] - adds or removes the player from the list
 
**Clearing lists**

- //sa [clear|c] - clears all alerts and shouts
 
- //sa [clear|c] [alerts|a|ignores|i] - clears specified list

**Toggles**

- //sa ls - Shows a window with the last shout for each alert
 
- //sa sound - Toggles the alert sound on/off

**Sets**

- //sa set - lists saved set names

- //sa set list - does the same thing as above.

- //sa set [setname] - loads [setname]

- //sa set [save|s] [setname] - saves current alerts to [setname]

- //sa set [remove|r] [setname] - removes [setname] from settings.xml

**Save**

- //sa [save] - saves all settings

**Examples**

- //sa add Zerde
- //sa add " Ou "
- //sa remove Zerde
- //sa ignore Gorby
- //sa ignore remove Gorby
- //sa set list
- //sa set save helms
- //sa set helms