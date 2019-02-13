#!/bin/sh

python2 vncdotool/vncdotool/command.py -s $1 \
	pause 2 \
	key meta-r \
	pause 2 \
	type "powershell" \
	key enter \
	pause 2 \
	type "echo Hello World" \
	pause 2 \
	key enter

