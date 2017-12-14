## Create chroot

    pacstrap -i -c -d /path/to/CONTAINER base --ignore linux


## Boot

    systemd-nspawn -b -D /path/to/CONTAINER
    
    passwd root


## Xorg permissions

    xhost +local:


## Sound

**/etc/asound.conf**

```
Use PulseAudio by default

pcm.!default {
  type pulse
  fallback "sysdefault"
  hint {
    show on
    description "Default ALSA Output (currently PulseAudio Sound Server)"
  }
}

ctl.!default {
  type pulse
  fallback "sysdefault"
}
```

**/etc/environment**

```
DISPLAY=:0
PULSE_SERVER=unix:/run/user/host/pulse/native
```


## systemd

**/etc/systemd/system/systemd-nspawn@CONTAINER.service.d/override.conf**

```
[Service]
DeviceAllow=/dev/dri rw
DeviceAllow=/dev/shm rw
DeviceAllow=/dev/nvidia0 rw
DeviceAllow=/dev/nvidiactl rw
DeviceAllow=/dev/nvidia-modeset rw
DeviceAllow=char-usb_device rwm 
DeviceAllow=char-input rwm 
DeviceAllow=char-alsa rwm 
ExecStart=
ExecStart=/usr/bin/systemd-nspawn -D /path/to/%I --quiet --keep-unit --boot --link-journal=try-guest --machine=%I
```

**/etc/systemd/nspawn/CONTAINER.nspawn**

```
[Exec]
Boot=1

[Files]
# nvidia-opengl
Bind=/tmp/.X11-unix
Bind=/dev/dri
Bind=/dev/shm
Bind=/dev/nvidia0
Bind=/dev/nvidiactl
Bind=/dev/nvidia-modeset

Bind=/dev/input
Bind=/run/user/1000/pulse:/run/user/host/pulse
Bind=/dev/snd

Bind=/media/Storage/Games
```
