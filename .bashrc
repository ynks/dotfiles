#
# ~/.bashrc
# By xein <3
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias n='nvim'
alias x='xmake'
alias g='git'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Alias for dotfiles backup
alias dotfiles='git -C $HOME --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Fancy PS1 text
function get_prompt_path() {
	local current_dir
	current_dir=$(pwd)

	if [[ "$current_dir" == "$HOME"* ]]; then
		echo "~${current_dir#$HOME}"
	else
		echo "$current_dir"
	fi
}
export PS1='\[\e[1;35m\]$(get_prompt_path)\[\e[0m\] > '
