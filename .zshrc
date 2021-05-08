## CONFIG ##
# p10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# funtoo keychain
eval $(keychain --eval id_rsa)
# source fzf config
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

SAVEHIST=1000
HISTSIZE=100
HISTFILE=/home/mat/.zsh_history

## ALIAS ##
# tip
alias ls="ls --color=auto"
# nvim
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
# docker
alias dps="docker ps"
alias da="docker attach"
alias de"docker exec -it"
# docker-compose
alias dc="docker-compose"
alias dcb="docker-compose build"
alias dcud="docker-compose up -d"
alias dcu="docker-compose up"
alias dcl="docker-compose logs -f --tail=1"
alias dce="docker-compose exec"
alias dcs="docker-compose stop"
alias dcd="docker-compose down"
alias dcr="docker-compose run"
# docker-compose tip
alias dgit="docker-compose exec wecasa git"
# chrome
alias protonmail="brave-browser-stable --app=\"https://beta.protonmail.com/\""
alias gmail="brave-browser-stable --app=\"https://mail.google.com/mail/u/2/\""
alias calendar="brave-browser-stable --app=\"https://calendar.protonmail.com/\""
alias deezer="brave-browser-stable --app=\"https://www.deezer.com/fr/\""
alias messenger="brave-browser-stable --app=\"https://www.messenger.com/\""
alias whatsapp="brave-browser-stable --app=\"https://web.whatsapp.com/\""
alias osm="brave-browser-stable --app=\"https://www.openstreetmap.org/\""
alias maps="brave-browser-stable --profile-directory=Default --app-id=bkaeedcadgimgkieaecleinibbmmohfd"

## FUNCTION ##
# xrandr
function screen() {
	xrandr --output eDP-1 --auto --output $1 --auto --scale 2x2 --right-of eDP-1
}
# chrome
function twitch() {
	brave-browser-stable --app="https://www.twitch.tv/$1"
}

## BINDKEY ##
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
