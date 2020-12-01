SAVEHIST=10
HISTFILE=~/.zsh_history

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

eval $(keychain --eval id_rsa)

# source fzf config
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# alias nvim
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# alias docker
alias dps="docker ps"

alias da="docker attach"
alias de"docker exec -it"

alias dc="docker-compose"
alias dcb="docker-compose build"
alias dcud="docker-compose up -d"
alias dcu="docker-compose up"
alias dcl="docker-compose logs -f --tail=1"
alias dce="docker-compose exec"
alias dcs="docker-compose stop"
alias dcd="docker-compose down"
alias dcr="docker-compose run"

alias dgit="docker-compose exec wecasa git"

# alias chrome
alias protonmail="brave-browser-stable --app=\"https://beta.protonmail.com/\""
alias gmail="brave-browser-stable --app=\"https://mail.google.com/mail/u/2/\""
alias calendar="brave-browser-stable --app=\"https://calendar.protonmail.com/\""
alias deezer="brave-browser-stable --app=\"https://www.deezer.com/fr/\""
alias messenger="brave-browser-stable --app=\"https://www.messenger.com/\""
alias whatsapp="brave-browser-stable --app=\"https://web.whatsapp.com/\""
function twitch() {
	brave-browser-stable --app="https://www.twitch.tv/$1"
}
alias osm="brave-browser-stable --app=\"https://www.openstreetmap.org/\""
alias maps="brave-browser-stable --profile-directory=Default --app-id=bkaeedcadgimgkieaecleinibbmmohfd"

alias ls="ls --color=auto"
function screen() {
	xrandr --output eDP-1 --auto --output $1 --auto --scale 2x2 --right-of eDP-1
}

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
