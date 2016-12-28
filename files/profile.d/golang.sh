#!/bin/bash

export GOROOT=$HOME/.go
export GOPATH=$HOME/Workspace/Go
export GOBIN=$GOPATH/bin
export PATH=$GOROOT/bin:$GOBIN:$PATH

cd () {
	builtin cd "$@"
	cdir=$PWD
	while [ "$cdir" != "/" ]; do
		if [ -e "$cdir/.gopath" ]; then
			export GOPATH=$cdir
			break
		fi
		cdir=$(dirname "$cdir")
	done
}

alias qq=". $GOPATH/src/github.com/y0ssar1an/q/q.sh"
alias rmqq="rm $TMPDIR/q"
