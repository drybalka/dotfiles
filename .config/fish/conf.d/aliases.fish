alias ls "eza --group-directories-first --sort=extension --git"
alias l "ls --long --smart-group"
alias ll "ls --long --smart-group --total-size --sort=size --reverse" # list largest
alias la "ls --long --smart-group --all" # list all
alias lt "ls --long --tree --level=2" # list truncated tree
alias lT "ls --long --tree" # list full tree

alias gl lazygit
alias diff "diff --color=auto"
alias rg "rg --pretty --smart-case"
alias dotfiles "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
