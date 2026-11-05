# NieR rice: the fastfetch status screen. Does nothing while the rice is off.
status is-interactive; or return
set -l __nier_state (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)/nier-rice/pre-nier
test -f $__nier_state; or return
function fastfetch --wraps fastfetch
    command fastfetch --config ~/.config/fastfetch/nier.jsonc $argv
end
