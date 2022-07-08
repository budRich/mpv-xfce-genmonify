This script will update a [xfce4-panel] [genmon] plugin
that is set up with [genmonify] to display the currently
playing media file and elpapsed or remaining time.  

Example settings (`~/.config/mpv/scrip-opts/xfce-genmonify.conf`):  
```text
pause_color=#EEEEEE
icon_click_command="mediacontrol toggle"
icon_playing=mpv
icon_paused=media-playback-start
time_remaining=yes
```

Setting up the genmonify thing:  
- install [genmon] and [genmonify]
- add a genmon instance, max out the time and set the command to `genmonify -o media`
- find the *internal xfce-panel ID* for the genmon instance (`genmonify --list`)
- add the line `modules[media]=ID` to `~/.config/genmonify/module-list`

![mpv-genmonify](https://user-images.githubusercontent.com/2143465/178037044-d78487f3-2c96-4478-b199-22048021def7.png)
