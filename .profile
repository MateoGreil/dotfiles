export EDITOR=/usr/bin/nano
export BROWSER=/usr/bin/brave-browser
export PATH=$PATH:/home/mat/.local/share/gem/ruby/2.7.0/bin:/home/mat/.cargo/bin:/home/mat/.bin

# Set keyboard
/usr/bin/setxkbmap -option "ctrl:nocaps"
/usr/bin/setxkbmap -option "compose:ralt"
/usr/bin/setxkbmap -rules evdev -layout us -model evdev
