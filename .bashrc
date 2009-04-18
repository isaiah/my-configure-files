# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

PS1="\[\033[1;36m\]\t \w$\[\033[32m\] "
alias ls="ls --color=auto"
alias v="vim"
alias fm="vifm"
alias ss="script/server"
alias sc="script/console"
alias ncmpc="ncmpcpp"
alias mplayer="mplayer -framedrop"
export MOZ_DISABLE_PANGO=1
# Put your fun stuff here.
