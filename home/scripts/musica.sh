#!/bin/bash 

#nohup kitty > /dev/null 2>&1 & 
hyprctl dispatch exec "[workspace 3] /usr/bin/chromium --profile-directory=Default --app-id=cinhimbnkkaeohfgghhklpknlkffjgod "
sleep 1 
hyprctl dispatch exec "[workspace 3] blueman-manager "
sleep 1 
hyprctl dispatch exec "[workspace 3] kitty -e cava "