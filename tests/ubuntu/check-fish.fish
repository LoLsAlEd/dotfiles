# Run through interactive startup so these assertions cover the installed config.
for fn in fish_prompt _atuin_search __zoxide_z fzf_configure_bindings _autopair_fish_key_bindings replay __done_is_process_window_focused
    functions --query $fn; or exit 1
end
functions fish_prompt | string match --quiet '*starship*'; or exit 1
for plugin in (string match --regex -- '^[^\s]+$' < $__fish_config_dir/fish_plugins)
    contains -- $plugin (fisher list); or exit 1
end
bind up | string match --quiet '*_atuin_bind_up*'; or exit 1
bind ctrl-r | string match --quiet '*_atuin_search*'; or exit 1
contains -- $HOME/.local/bin $PATH; or exit 1
test "$SHELL" = /usr/bin/fish; or exit 1
ls >/dev/null; or exit 1
ll >/dev/null; or exit 1
l >/dev/null; or exit 1
lt >/dev/null; or exit 1
cat --paging=never README.md >/dev/null; or exit 1
fd --max-results 1 . >/dev/null; or exit 1
echo '[PASS] Interactive Fish tools, hooks, plugins, and wrappers'
