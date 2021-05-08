# ENV VARIABLES
export EDITOR=/usr/bin/nano
export BROWSER=/usr/bin/brave-browser
export PATH=$PATH:/home/mat/.cargo/bin:/home/mat/.bin
# zsh
export SAVEHIST=1000
export HISTSIZE=100
export HISTFILE=/home/mat/.zsh_history


# Set keyboard
/usr/bin/setxkbmap -option "ctrl:nocaps"
/usr/bin/setxkbmap -option "compose:ralt"
/usr/bin/setxkbmap -rules evdev -layout us -model evdev
