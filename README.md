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

**Saving lists**

- //sa [save] - saves the lists to the settings.xml

**Examples**

- //sa add Zerde
- //sa add " Ou "
- //sa ignore Gorby
- //sa remove Zerde
