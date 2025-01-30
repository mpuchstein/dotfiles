#!/usr/bin/bash
notify-send "Restarting hyprpanel"
uwsm app -- /usr/bin/hyprpanel -q 
sleep 1
uwsm app -- /usr/bin/hyprpanel &
