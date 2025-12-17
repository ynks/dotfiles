#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

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
