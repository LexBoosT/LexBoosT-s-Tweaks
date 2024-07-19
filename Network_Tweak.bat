@echo Off
netsh interface tcp set heuristics disabled
ipconfig /flushdns
ipconfig /registerdns
exit
