# TES3MP Deploy Script
### A pair of scripts for easily installing and upgrading TES3MP
<grimkriegor@krutt.org>

When placed in an empty folder these scripts are able to create a folder hierarchy, install the system dependencies, based on your distro, download the code for TES3MP, OSG, Bullet, RakNet and Terra, compile everything and also upgrade it from the latest git changes whenever necessary.

This script pair also keeps the config files and plugins in a separate folder, to avoid having your changes overwritten whenever an upgrade occurs.

They are pretty bare and have no redundancy (yet), if you feel like testing it, come, testervar, friend or traitor, come.

--


**install.sh** -- Creates the folder hierarchy, installs system dependencies, downloads the code, builds RakNet and Terra and launches upgrade.sh

    -c, --cores N : Use N threads for building TES3MP and its dependencies

    -s, --server-only : Install as server only, do not build the client

**upgrade.sh** -- Pulls the latest TES3MP code and if there are any changes, rebuilds the project, keeping the config files safe via symlinks

    -c, --cores N : Use N threads for building TES3MP and its dependencies

    -i, --install : Build TES3MP without asking, useful when being called by upgrade.sh

    -u, --check-changes : Upgrade without asking, if there are changes in the upstream code, useful for scheduled auto-upgrading

--

Currently supports: Arch Linux, Parabola GNU/Linux-libre, Debian, Devuan, Ubuntu, Linux Mint and Fedora.

Big thanks to Norc for his intense testing, debugging and fix suggestions.
