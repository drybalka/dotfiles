function fd --wraps fd --description 'Better find files with fd and eza'
    command fd --hidden --no-ignore --list-details $argv \
        --exec-batch eza --group-directories-first --sort=extension --git --long --smart-group
end
