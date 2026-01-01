# Set cursor to slim line
set -g fish_cursor_default line

if status is-interactive
    starship init fish | source
    zoxide init fish | source
end
