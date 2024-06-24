@echo off
color F0
title Revert Standard Services By LexBoosT
mode con: cols=72 lines=21
cls

sc config AJRouter start= demand > nul

sc config AppXSvc start= demand > nul

sc config ALG start= demand > nul

sc config AppMgmt start= demand > nul
 
sc config AppReadiness start= demand > nul

sc config tzautoupdate start= demand > nul
 
sc config AssignedAccessManagerSvc start= demand > nul

sc config BITS start= delayed-auto > nul

sc config BDESVC start= demand > nul

sc config wbengine start= demand > nul

sc config BTAGService start= demand > nul

sc config bthserv start= demand > nul
 
sc config BthHFSrv start= demand > nul

sc config PeerDistSvc start= demand > nul

sc config CertPropSvc start= demand > nul

sc config ClipSVC start= demand > nul

sc config DiagTrack start= auto > nul

sc config VaultSvc start= auto > nul

sc config CDPSvc start= demand > nul

sc config DusmSvc start= auto > nul

sc config DoSvc start= delayed-auto > nul

sc config diagsvc start= demand > nul

sc config DPS start= auto > nul

sc config WdiServiceHost start= demand > nul

sc config WdiSystemHost start= demand > nul

sc config TrkWks start= auto > nul

sc config MSDTC start= demand > nul

sc config dmwappushservice start= demand > nul

sc config DisplayEnhancementService start= demand > nul

sc config MapsBroker start= delayed-auto > nul

sc config fdPHost start= demand > nul

sc config FDResPub start= demand > nul

sc config EFS start= demand > nul

sc config EntAppSvc start= demand > nul

sc config fhsvc start= demand > nul

sc config lfsvc start= demand > nul

sc config GraphicsPerfSvc start= demand > nul

sc config HomeGroupListener start= demand > nul

sc config HomeGroupProvider start= demand > nul

sc config HvHost start= demand > nul

sc config hns start= demand > nul

sc config vmickvpexchange start= demand > nul

sc config vmicguestinterface start= demand > nul

sc config vmicshutdown start= demand > nul

sc config vmicheartbeat start= demand > nul

sc config vmicvmsession start= demand > nul

sc config vmicrdv start= demand > nul

sc config vmictimesync start= demand > nul

sc config vmicvss start= demand > nul

sc config IEEtwCollectorService start= demand > nul

sc config lltdsvc start= demand > nul

sc config iphlpsvc start= auto > nul

sc config IpxlatCfgSvc start= demand > nul

sc config PolicyAgent start= demand > nul

sc config irmon start= demand > nul

sc config SharedAccess start= demand > nul

sc config diagnosticshub.standardcollector.service start= demand > nul

sc config wlidsvc start= demand > nul

sc config AppVClient start= demand > nul

sc config NgcSvc start= demand > nul
 
sc config NgcCtnrSvc start= demand > nul

sc config smphost start= demand > nul

sc config InstallService start= demand > nul

sc config SmsRouter start= demand > nul

sc config MSiSCSI start= demand > nul

sc config NaturalAuthentication start= demand > nul

sc config NetTcpPortSharing start= demand > nul
  
sc config Netlogon start= demand > nul

sc config NcdAutoSetup start= demand > nul

sc config NcbService start= auto > nul

sc config NcaSvc start= demand > nul

sc config CscService start= demand > nul

sc config defragsvc start= demand > nul

sc config SEMgrSvc start= demand > nul

sc config PNRPsvc start= demand > nul

sc config p2psvc start= demand > nul

sc config p2pimsvc start= demand > nul

sc config pla start= demand > nul

sc config PhoneSvc start= demand > nul

sc config WPDBusEnum start= demand > nul

sc config Spooler start= auto > nul

sc config PrintNotify start= demand > nul

sc config PcaSvc start= auto > nul

sc config WpcMonSvc start= demand > nul

sc config QWAVE start= demand > nul

sc config RasAuto start= demand > nul

sc config RasMan start= demand > nul

sc config SessionEnv start= demand > nul

sc config TermService start= demand > nul

sc config UmRdpService start= demand > nul

sc config RpcLocator start= auto > nul

sc config RemoteRegistry start= demand > nul

sc config RetailDemo start= demand > nul

sc config RemoteAccess start= demand > nul

sc config RmSvc start= demand > nul

sc config SNMPTRAP start= demand > nul

sc config seclogon start= demand > nul

sc config wscsvc start= delayed-auto > nul

sc config SamSs start= demand > nul

sc config SensorDataService start= demand > nul

sc config SensrSvc start= demand > nul

sc config SensorService start= demand > nul

sc config LanmanServer start= auto > nul

sc config shpamsvc start= demand > nul
 
sc config ShellHWDetection start= auto > nul

sc config SCardSvr start= demand > nul

sc config ScDeviceEnum start= demand > nul

sc config SCPolicySvc start= demand > nul

sc config SharedRealitySvc start= demand > nul

sc config StorSvc start= demand > nul

sc config TieringEngineService start= demand > nul

sc config SysMain start= auto > nul

sc config SgrmBroker start= delayed-auto > nul

sc config lmhosts start= auto > nul

sc config TapiSrv start= demand > nul

sc config Themes start= auto> nul

sc config tiledatamodelsvc start= auto > nul

sc config TabletInputService start= demand > nul

sc config UsoSvc start= demand > nul

sc config UevAgentService start= demand > nul

sc config WalletService start= demand > nul

sc config wmiApSrv start= demand > nul

sc config WwanSvc start= demand > nul

sc config TokenBroker start= demand > nul

sc config WebClient start= demand > nul

sc config WFDSConMgrSvc start= demand > nul

sc config SDRSVC start= demand > nul

sc config WbioSrvc start= auto > nul

sc config FrameServer start= demand > nul

sc config wcncsvc start= demand > nul

sc config Sense start= demand > nul

sc config WdNisSvc start= demand > nul

sc config WinDefend start= auto > nul

sc config SecurityHealthService start= auto > nul

sc config WEPHOSTSVC start= demand > nul

sc config WerSvc start= demand > nul

sc config Wecsvc start= demand > nul

sc config FontCache start= auto > nul

sc config StiSvc start= delayed-auto > nul

sc config wisvc start= demand > nul

sc config LicenseManager start= demand > nul

sc config icssvc start= demand > nul

sc config WMPNetworkSvc start= demand > nul

sc config FontCache3.0.0.0 start= auto > nul

sc config WpnService start= auto > nul

sc config perceptionsimulation start= demand > nul

sc config spectrum start= demand > nul

sc config WinRM start= demand > nul

sc config WSearch start= delayed-auto > nul

sc config SecurityHealthService start= auto > nul
 
sc config W32Time start= demand > nul

sc config wuauserv start= demand > nul

sc config WaaSMedicSvc start= demand > nul

sc config LanmanWorkstation start= auto > nul

sc config XboxGipSvc start= demand > nul

sc config xbgm start= demand > nul

sc config XblAuthManager start= demand > nul

sc config XblGameSave start= demand > nul

sc config XboxNetApiSvc start= demand > nul

sc config WlanSvc start= auto > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BluetoothUserService" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CaptureService" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ConsentUxUserSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\PimIndexMaintenanceSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DevicePickerUserSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DevicesFlowUserSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BcastDVRUserService" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MessagingService" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\PrintWorkflowUserSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\OneSyncSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UserDataSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UnistoreSvc" /v Start /t REG_DWORD /d 00000002 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpnUserService" /v Start /t REG_DWORD /d 00000002 /f > nul

echo Windows Services by default succes!

timeout 5 > nul
cls

echo Enable Standard Services Tweaks!

sc stop AJRouter > nul
sc config AJRouter start= disabled > nul

sc stop tzautoupdate > nul
sc config tzautoupdate start= disabled > nul

sc stop BITS > nul
sc config BITS start= disabled > nul

sc stop DiagTrack > nul
sc config DiagTrack start= disabled > nul
 
sc stop CDPSvc > nul
sc config CDPSvc start= disabled > nul

sc stop DusmSvc > nul
sc config DusmSvc start= disabled > nul

sc stop DoSvc > nul
sc config DoSvc start= disabled > nul

sc stop diagsvc > nul
sc config diagsvc start= disabled > nul

sc stop DPS > nul
sc config DPS start= disabled > nul

sc stop WdiServiceHost > nul
sc config WdiServiceHost start= disabled > nul

sc stop WdiSystemHost > nul
sc config WdiSystemHost start= disabled > nul

sc stop dmwappushservice > nul
sc config dmwappushservice start= disabled > nul

sc stop DisplayEnhancementService > nul
sc config DisplayEnhancementService start= disabled > nul

sc stop MapsBroker > nul
sc config MapsBroker start= disabled > nul

sc stop fhsvc > nul
sc config fhsvc start= disabled > nul

sc stop lfsvc > nul
sc config lfsvc start= disabled > nul

sc stop HomeGroupListener > nul
sc config HomeGroupListener start= disabled > nul

sc stop HomeGroupProvider > nul
sc config HomeGroupProvider start= disabled > nul

sc stop SmsRouter > nul
sc config SmsRouter start= disabled > nul

sc stop CscService > nul
sc config CscService start= disabled > nul

sc stop SEMgrSvc > nul
sc config SEMgrSvc start= disabled > nul

sc stop pla > nul
sc config pla start= disabled > nul

sc stop PhoneSvc > nul
sc config PhoneSvc start= disabled > nul

sc stop WpcMonSvc > nul
sc config WpcMonSvc start= disabled > nul

sc stop RasAuto > nul
sc config RasAuto start= disabled > nul

sc stop RasMan > nul
sc config RasMan start= disabled > nul 

sc stop SessionEnv > nul
sc config SessionEnv start= disabled > nul

sc stop TermService > nul
sc config TermService start= disabled > nul

sc stop TermService > nul
sc config TermService start= disabled > nul
 
sc stop RpcLocator > nul
sc config RpcLocator start= disabled > nul

sc stop RemoteRegistry > nul
sc config RemoteRegistry start= disabled > nul
 
sc stop RetailDemo > nul
sc config RetailDemo start= disabled > nul

sc stop SysMain > nul 
sc config SysMain start= disabled > nul

sc stop WalletService > nul
sc config WalletService start= disabled > nul

sc stop WerSvc > nul
sc config WerSvc start= disabled > nul

sc stop WSearch > nul
sc config WSearch start= disabled > nul
 
sc stop W32Time > nul 
sc config W32Time start= disabled > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BcastDVRUserService" /v Start /t REG_DWORD /d 00000004 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MessagingService" /v Start /t REG_DWORD /d 00000004 /f > nul

reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpnUserService" /v Start /t REG_DWORD /d 00000004 /f > nul

cls
echo Thank you for using my optimizations!
timeout 3 > nul
cls
echo Exiting.
timeout 1 > nul
cls
echo Exiting..
timeout 1 > nul
cls
echo Exiting...
timeout 1 > nul
exit