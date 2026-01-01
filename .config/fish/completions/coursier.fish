function _coursier_completion
    coursier complete fish-v1 (math 1 + (count (__fish_print_cmd_args))) (__fish_print_cmd_args)
end

complete -c coursier -a "(_coursier_completion)"
complete -c cs -a "(_coursier_completion)"
