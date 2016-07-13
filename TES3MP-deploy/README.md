# TES3MP Deploy Script

!!! WIP !!!

When placed in an empty folder these scripts are able to create a folder hierarchy, download the code for TES3MP, RakNet and Terra, compile everything and also upgrade it from the latest git changed whenever necessary.

This script pair also keeps tes3mp-client-default.cfg and tes3mp-server-default.cfg in a separate folder, to avoid having your changes overwritten whenever an upgrade occurs.

They are pretty bare and have no redundancy (yet), if you feel like testing it, come, testervar, friend or traitor, come.

>> install.sh - Creates the folder hierarchy, downloads the code, builds dependencies and launches upgrade.sh
>> upgrade.sh - Pulls the latest TES3MP code and if there are any changes, rebuilds the project, keeping the config files safe via symlinks
