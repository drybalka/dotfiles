HISTFILE=$HOME/.cache/zsh_history
HISTSIZE=10000
SAVEHIST=10000
unsetopt beep
setopt HIST_IGNORE_DUPS
setopt share_history

zstyle :compinstall filename $HOME/.zshrc
autoload -Uz compinit
compinit -d $HOME/.cache/zcompdump
# source /usr/bin/aws_zsh_completer.sh

# History search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Change cursor shape to beam
function zle-keymap-select zle-line-init zle-line-finish { print -n "\e[6 q" }
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# Allow jumping between prompts in foot
precmd() {
    print -Pn "\e]133;A\e\\"
}

# Allow spawning new terminals in same cwd
function osc7-pwd() {
    emulate -L zsh # also sets localoptions for us
    setopt extendedglob
    local LC_ALL=C
    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}
function chpwd-osc7-pwd() {
    (( ZSH_SUBSHELL )) || osc7-pwd
}
autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd chpwd-osc7-pwd

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bold"
HISTORY_SUBSTRING_SEARCH_FUZZY=true # fuzzy search by words

# Map key bindings
bindkey -N clean
bindkey -A clean main

bindkey -R " "-"~" self-insert
bindkey -R "\M-^@"-"\M-^?" self-insert

bindkey "^[[200~" bracketed-paste   # properly handle pasting into terminal
bindkey "^M" accept-line            # map Enter key
# bindkey "^J" accept-line
# bindkey "^V" quoted-insert

bindkey "^L" clear-screen
bindkey "^Y" autosuggest-accept
bindkey "^H" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^K" backward-kill-line
bindkey "^J" kill-line
bindkey "^L" delete-char
bindkey "^B" beginning-of-line
bindkey "^E" end-of-line
bindkey "^P" history-substring-search-up
bindkey "^N" history-substring-search-down
bindkey "\eh" backward-char
bindkey "\el" forward-char
bindkey "\ek" backward-word
bindkey "\ej" forward-word

typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Tab]="${terminfo[ht]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[Ctrl-Left]="${terminfo[kLFT5]}"
key[Ctrl-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Home]}"       ]] && bindkey "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"        ]] && bindkey "${key[End]}"        end-of-line
[[ -n "${key[Backspace]}"  ]] && bindkey "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"     ]] && bindkey "${key[Delete]}"     delete-char
[[ -n "${key[Tab]}"        ]] && bindkey "${key[Tab]}"        expand-or-complete
[[ -n "${key[Shift-Tab]}"  ]] && bindkey "${key[Shift-Tab]}"  reverse-menu-complete
[[ -n "${key[Up]}"         ]] && bindkey "${key[Up]}"         up-line-or-beginning-search
[[ -n "${key[Down]}"       ]] && bindkey "${key[Down]}"       down-line-or-beginning-search
[[ -n "${key[Left]}"       ]] && bindkey "${key[Left]}"       backward-char
[[ -n "${key[Right]}"      ]] && bindkey "${key[Right]}"      forward-char
[[ -n "${key[Ctrl-Left]}"  ]] && bindkey "${key[Ctrl-Left]}"  backward-word
[[ -n "${key[Ctrl-Right]}" ]] && bindkey "${key[Ctrl-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Aliases
alias ls="eza --group-directories-first --sort=extension"
alias l="eza -lg --group-directories-first --sort=extension --git"
alias la="eza -lag --group-directories-first --sort=extension --git"
alias lt="eza -l --group-directories-first --sort=extension --tree --level=2 --git"
alias lT="eza -l --group-directories-first --sort=extension --tree --git"
alias rg="rg --pretty --smart-case"
alias diff="diff --color=auto"
alias hx="helix"

alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

fd () {
    /usr/bin/fd -HI "$@" -X eza -ld --group-directories-first --sort=extension --git
}

# Status line
eval "$(starship init zsh)"

# Set correct gpg tty for pinenetry
export GPG_TTY=$(tty)
gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
