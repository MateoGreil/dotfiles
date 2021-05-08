## ENV VARIABLES ##
export EDITOR=/usr/bin/nano
export BROWSER=/usr/bin/brave-browser
export PATH=$PATH:/home/mat/.cargo/bin:/home/mat/.bin

## KEYBOARD ##
/usr/bin/setxkbmap -option "ctrl:nocaps"
/usr/bin/setxkbmap -option "compose:ralt"
/usr/bin/setxkbmap -rules evdev -layout us -model evdev
