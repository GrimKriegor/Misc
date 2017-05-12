# Grim's Ultra Cool Conky Config

The Conky setup I've been using and improving since 2009

![](https://raw.githubusercontent.com/GrimKriegor/Misc/master/Conky/preview.png)


## Configuration

**conkyrc.clean** is an alternate version of my conkyrc with the private data stripped out via **private-data-stripper.sh**

Configure and rename **conkyrc.clean** as **conkyrc**

**conkyrc** and **draw_bg.lua** go in **$HOME/.conky**

Enable the following modules by creating a file with their name in **$HOME/.config/conky/**

**CPU Type**

- cpu2 (Dual-core CPU)
- cpu4 (Quad-core CPU)
- cpu8 (Octa-core CPU)

**Hard drives**

- lvm (Logical partitions instead of physical ones)
- hdd_auxiliary (Extra hdd)

**Extra hardware**

- battery (Laptop Battery)
- nvidia (NVIDIA temperature indicator)

**Network interfaces**

- eth0 (Ethernet)
- wlan0 (WiFi)
- tethering (USB Tethering)
- zalkeen (VPN)

**Network Status**

- zalkeenstatus (Information about VPS conectivity)
- hyperboria (Information about the Hyperboria link)


## Running

   conky --config=$HOME/.conky/conkyrc


## Licenses

The config is released under the GNU General Public License v3

Lua background (draw_bg.lua) by londonali1010 and VinDSL (2009-2011) released under public domain
