typeset -U PATH path
path=("$HOME/.local/bin" "$HOME/.local/share/coursier/bin" "$HOME/.cargo/bin" "$path[@]")
export PATH

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export QT_QPA_PLATFORM="wayland;xcb"
export __EGL_VENDOR_LIBRARY_FILENAMES="/usr/share/glvnd/egl_vendor.d/50_mesa.json"

export LESSHISTFILE=-
export BEMENU_OPTS="-i"
export EDITOR=hx
export SUDO_EDITOR=hx
export PAGER=bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export _JAVA_AWT_WM_NONREPARENTING=1
