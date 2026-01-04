# Clear default non-typing bindings
bind --erase --all --preset
bind '' self-insert

bind ctrl-y accept-autosuggestion
bind ctrl-space edit_command_buffer

bind ctrl-l delete-char
bind ctrl-h backward-delete-char
bind ctrl-j kill-line
bind ctrl-k backward-kill-line
bind ctrl-e kill-word
bind ctrl-w backward-kill-word

bind alt-l forward-char
bind alt-h backward-char
bind alt-j end-of-line
bind alt-k beginning-of-line
bind alt-e forward-word
bind alt-w backward-word

bind up history-prefix-search-backward
bind down history-prefix-search-forward
bind ctrl-p history-search-backward
bind ctrl-n history-search-forward
bind alt-p history-token-search-backward
bind alt-n history-token-search-forward
