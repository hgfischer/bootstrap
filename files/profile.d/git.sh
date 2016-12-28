#!/bin/bash

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
	GIT_PROMPT_THEME=Single_line_openSUSE
	source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi
