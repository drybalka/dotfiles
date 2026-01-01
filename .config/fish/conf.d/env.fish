fish_add_path --prepend --path "$HOME/.local/bin" "$HOME/.local/share/coursier/bin"

set -gx LESSHISTFILE -
set -gx EDITOR hx
set -gx SUDO_EDITOR hx

# Needed to start ssh-agent with systemd user on login
# See https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

# Use fuzzel menu as out-of-terminal password prompt for ssh
set -gx SSH_ASKPASS askpass-fuzzel

# This is needed to avoid loading NVIDIA modules before launching sway
# See https://wiki.archlinux.org/title/Wayland#Avoid_loading_NVIDIA_modules
set -gx __EGL_VENDOR_LIBRARY_FILENAMES "/usr/share/glvnd/egl_vendor.d/50_mesa.json"

### Possibly outdated settings

# This might be needed to force qt applications to use wayland compositor
# See https://wiki.archlinux.org/title/Wayland#Qt
# set -gx QT_QPA_PLATFORM "wayland;xcb"

# This might be needed to run java applications under Wayland
# See https://wiki.archlinux.org/title/Java
# set -gx _JAVA_AWT_WM_NONREPARENTING 1
