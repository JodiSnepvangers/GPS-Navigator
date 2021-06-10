# GPS Navigator for Computer Craft
This is a script meant for Computer Craft, a mod for minecraft which allows for programming with in game computers.

This is a Lua script meant to run on a Computer Craft Advance Pocket Computer. It can store locations given to it and using a GPS signal, it can relocate the user towards the stored locations.


## Saving Locations
The Save option on the main menu allows locations to be saved in memory. Inside this menu, a new unique name must be entered followed by the X, Y and Z coordinate, which will be prefilled if a GPS Signal is present. 

Sequence Input will ask for all three coordinates one after another, to allow rapid typing.

## Editing Locations
Edit lets you view all saved locations in memory, and once one is selected, it reopens it in the save menu, allowing its data to be rewritten.

## Deleting Location
Delete opens the list of stored locations, and once one is selected, it is erased completely. Beware, this cannot be undone!

## List Locations
Many options will show a list of options. Any of the locations can be selected for the option that was requested on the main menu. 

### Different Views
there is a button at the top right of the screen that will change the list displayed.

Simple View is the most basic of all, meant for easy looking.

Dual View doubles the amount of data shown, showing locations in each column.

Distance View will show how many blocks away the location is from your current position (only if a GPS signal is present).

## Load Location
The final option lets you load a location into the GPS Display. The Display will show a cross into the direction of the chosen location. Align your character with the compass and walk into that direction to go towards your destination. Optionally, you can rotate the entire compass by 90 degrees by pressing the arrow buttons on either side.

## How to install
To install this on a pocket computer, either move the script files into the computercraft directory inside the world's folder. Alternatively, you can type out 'pastebin get jPGuQwRk NavInstall' into the pocket computer, then type NavInstall which will get the required scripts. 

once the scripts are on the pocket computer, run 'Navigator' to start the program (dont run any of the other scripts on their own!)

Note: the settings option on the main menu is not yet implemented.