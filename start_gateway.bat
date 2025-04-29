REM needed for large area detector arrays

set GWEXT_CONSOLEPORT=9003

set EPICS_CA_MAX_ARRAY_BYTES=20000
set EPICS_CA_ADDR_LIST=130.246.39.152:5066
set EPICS_CAS_AUTO_BEACON_ADDR_LIST=NO
set EPICS_CAS_BEACON_ADDR_LIST=127.255.255.255
set EPICS_CAS_INTF_ADDR_LIST=127.0.0.1
set EPICS_CA_AUTO_ADDR_LIST=NO

set GWEXT_ARGS=-home c:/gateway/home ^
  -command c:/gateway/command ^
  -pvlist c:/gateway/gw_webdashboard.pvlist ^
  -access c:/gateway/gw_webdashboard.acf ^
  -caputlog localhost ^
  -report external_report.log ^
  -sip 127.0.0.1 ^
  -cip 130.246.39.152:5066 ^
  -prefix TE:GW_WEBDASH:CS:GATEWAY:EXTERNAL ^
  -archive ^
  -no_cache ^
  -debug 0 ^
  -log C:/gateway/gateway.log


C:\gateway\gateway.exe %GWEXT_ARGS%
