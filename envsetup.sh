#!/bin/bash

export LKP_SRC=$PWD
export PATH=$PATH:$LKP_SRC/bin

_lkp() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD-1]}
	COMPREPLY=()

	case "$prev" in
		lkp)
			bins=$(ls $LKP_SRC/bin)
			sbins=$(ls $LKP_SRC/sbin)
			lkp_execs=$(ls $LKP_SRC/lkp-exec)
			tools=$(ls $LKP_SRC/tools)
			completions="$bins $sbins $lkp_execs $tools"
			COMPREPLY=( $( compgen -W "$completions" -- $cur ))
			;;
	esac

	return 0
}

complete -o default -F _lkp lkp
