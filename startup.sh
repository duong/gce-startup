#!/bin/bash

# install stuff
sudo apt install zsh zplug gawk tmux -y

# create .zshrc so when new users are created, zsh is already configured
cat <<EOF > /etc/skel/.zshrc
# Set path if required
#export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ec="$EDITOR $HOME/.zshrc" # edit .zshrc
alias sc="source $HOME/.zshrc"  # reload zsh configuration

# Use vi keybindings even if our EDITOR is set to vi
bindkey -e

setopt histignorealldups sharehistory

# Keep 5000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

# zplug - manage plugins
source /usr/share/zplug/init.zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh       # Gets rid of command not found error message
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
zplug "junegunn/fzf"
zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

# pure theme colors
PINK='#fa68bd'
LIGHT_GREEN='#55e787'
LIGHT_BLUE='#55c3fb'
DARK_GREY='#282a36'

zmodload zsh/nearcolor
autoload -U promptinit; promptinit

# optionally define some options
PURE_CMD_MAX_EXEC_TIME=10

# change the path color
zstyle :prompt:pure:path color '#55e787'

# change the color for both `prompt:success` and `prompt:error`
zstyle ':prompt:pure:prompt:*' color cyan

# change the username@host
zstyle ':prompt:pure:user' color '#55c3fb'
zstyle ':prompt:pure:host' color '#55c3fb'

# turn on git stash status
zstyle :prompt:pure:git:stash show yes

autoload -U promptinit; promptinit

zplug install
zplug load --verbose

# use tmux https://unix.stackexchange.com/questions/43601/how-can-i-set-my-default-shell-to-start-up-tmux or https://wiki.archlinux.org/title/Tmux#Start_tmux_on_every_shell_login
# if tmux is executable and not inside a tmux session, then try to attach.
# if attachment fails, start a new session
[ -x "$(command -v tmux)" ] \
  && [ -z "${TMUX}" ] \
  && { tmux attach || tmux; } >/dev/null 2>&1

EOF

# change default shell to zsh. This seems like it doesn't really do anything
sed -i 's#DSHELL=/bin/bash#DSHELL=/bin/zsh#g' /etc/adduser.conf

# Initialize shell as zsh. This seemse better than DSHELL
# https://stackoverflow.com/questions/33292541/how-do-i-change-my-default-shell-in-ubuntu-when-not-in-etc-passwd
cat <<EOT >> /etc/skel/.profile
if [ "${SHELL}" != '/bin/zsh' ]
then
    export SHELL='/bin/zsh/'
    exec /bin/zsh -l # -l: login shell again
fi
EOT

# create .tmux.conf https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/
cat <<EOF > /etc/skel/.tmux.conf
set -g default-terminal "xterm-256color"

# loud or quiet?
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none

#  modes
setw -g clock-mode-colour colour5
setw -g mode-style 'fg=colour1 bg=colour18 bold'

# panes
set -g pane-border-style 'fg=colour19 bg=colour0'
set -g pane-active-border-style 'bg=colour0 fg=colour9'

# statusbar
set -g status-position bottom
set -g status-justify left
set -g status-style 'bg=colour18 fg=colour137 dim'
set -g status-left ''
set -g status-right '#[fg=colour233,bg=colour19] %d/%m #[fg=colour233,bg=colour8] %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20

setw -g window-status-current-style 'fg=colour1 bg=colour19 bold'
setw -g window-status-current-format ' #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F '

setw -g window-status-style 'fg=colour9 bg=colour18'
setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

setw -g window-status-bell-style 'fg=colour255 bg=colour1 bold'

# messages
set -g message-style 'fg=colour232 bg=colour16 bold'

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

EOF

echo "done"

