@echo off
:: ================================ 修订记录 =======================================
:: 2014-01-20  3.1
::                *  中文全部替换成英文
::                *  add screencap 
::                *  remove ping cmd when get d sysrq 
::                *  add colors 
::                *  add new modem log
::                *  add screencap 
::                *  add delete option
::                *  add adb detect
:: 2014-01-27  3.2
::                *  fix ls list /sdcard directory fail
::                *  add modem_state log
::                *  add k3v3 sec os log
:: 2014-01-27  3.3
::                *  delete logservice log
::                *  add delete options for product line
:: 2014-02-19  3.4
::                *  support recovery mod
::                *  move logserver log to new directory
::                *  remove nvme
:: 2014-02-25  3.5
::                *  support new modem_state
::                *  get all modem_om/balong_om/log
::
:: 2014-03-10  3.6
::                *  get via modem log
::                *  get all log from /sdcard/log /data/log
::                *  support all init service status print
:: 2014-03-24  3.7
::                * add /data/modemlog/Log
::                * add /data/hifi log
::                * add etb log 
::                * change modem_om/balong/log to /modem_om /modem_log
:: 2014-04-10  3.8
::                * fix user phone get log failed, delete ls directory 
::                * add hifi log trigger
::                * add unified log directory
:: 2014-04-15  3.9
::                * remove secos log
::                * add delete hwzd_logs hisi_logs
:: 2014-04-26  3.10
::                * add k3v3 boardid
::                * delete all modem log
:: 2014-05-19  3.11
::                *  support boardid & boardname & modemid
set ver_str=4.0
echo =====================GetLog version %ver_str% ================================
:: echo Current: %time% 即 %time:~0,2%点%time:~3,2%分%time:~6,2%秒%time:~9,2%厘秒@
echo ####Current: %date% %time%

set date_time="%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%"
set Folder="Logs_%ver_str%_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
echo ####start to get log to (%CD%\%Folder%)...
mkdir %Folder%

adb start-server
adb devices|findstr /e device
if %errorlevel% EQU 0 (
  echo ####find devices ................ [device] .........................
  goto START
)
adb devices|findstr /e recovery
if %errorlevel% EQU 0 (
  echo ####find devices ................ [recovery] .........................
  goto START
)
 
echo  !!!!!!!!!!!!!!!!!Can't find device!!!!!!!!!!!!!!!!!!!
goto END

:START
echo ####
set ap_opt=1
if %ap_opt% EQU 1 (
    set ap_opt=1
) else (
    set ap_opt=0
)

set cp_opt=1
if %cp_opt% EQU 1 (
    set cp_opt=1
) else (
    set cp_opt=0
)

::======================board id============================================
:: get board id
echo ####get boardid to boardid.txt
echo boardid sequence:                       boardid_0  boardid_1  boardid_2 > %Folder%/boardid.txt
adb shell cat /dev/boardconfig_fs | findstr "hisi,boardid" >> %Folder%/boardid.txt
echo ####get boardname to boardname.txt
adb shell cat /dev/boardconfig_fs | findstr "hisi,boardname" > %Folder%/boardname.txt
echo ####get modemid to modemid.txt
adb shell cat /dev/boardconfig_fs | findstr "hisi,modem_id" > %Folder%/modemid.txt
::======================Android light log===================================
:: common logs from android
echo ####get dmesg to dmesg.txt ...
adb shell  dmesg > %Folder%\dmesg.txt
echo ####get ps list to ps.txt ...
adb shell  ps > %Folder%\ps.txt
echo ####get ps thread list to ps_t.txt ...
adb shell  ps -t > %Folder%\ps_t.txt
echo ####get properties to prop.txt ...
adb shell  getprop > %Folder%\prop.txt
echo ####get cmdline to cmdline.txt ...
adb shell  cat /proc/cmdline > %Folder%\cmdline.txt
echo ####get main logcat to logcat.txt ...
adb shell  logcat -v threadtime -d -t 1000 > %Folder%\logcat.txt
echo ####get dontpanic to .\dontpanic ...
adb pull   /data/dontpanic/  %Folder%\dontpanic\
echo ####get dropbox to .\dropbox ...
adb pull   /data/system/dropbox/  %Folder%\dropbox\
echo ####get tombstones to .\tombstones ...
adb pull   /data/tombstones/  %Folder%\tombstones\
echo ####get anr to .\anr ...
adb pull   /data/anr/ %Folder%\anr\
echo ####get data file list to .\userdata_check.txt ...
adb shell ls -lR /data  > %Folder%/userdata_check.txt
echo ####get system file list to .\system_check.txt
adb shell ls -lR /system > %Folder%/system_check.txt
echo ####get D state process to dmesg_sysrq.txt ...
adb shell "echo 1 > /proc/sys/kernel/sysrq"
adb shell "echo w > /proc/sysrq-trigger"
adb shell  dmesg > %Folder%/dmesg_sysrq.txt
echo ####get all init service status to .\dmesg_service.txt
adb shell setprop sys.printservice all
adb shell dmesg > %Folder%/demsg_service.txt
echo ####get balong_power modem_state to .\modem_state.txt
adb shell ls /sys/devices/platform/balong_power/ | findstr /X modem_state
if %errorlevel% EQU 0 (
  adb shell cat /sys/devices/platform/balong_power/modem_state > %Folder%\modem_state.txt
) else (
  adb shell cat /sys/devices/platform/balong_power/state > %Folder%\modem_state.txt
)

mkdir %Folder%\etb
adb pull /data/etb.bin %Folder%/etb
adb pull /sdcard/SrTestLog.txt %Folder%/SrTestLog.txt
adb pull /data/testlog.txt %Folder%/testlog.txt
adb pull /data/processInfo.txt %Folder%/processInfo.txt
adb pull /sdcard/rebootLog.txt %Folder%/rebootLog.txt
adb pull /sdcard/result.txt %Folder%/result.txt
adb pull /sdcard/freq_count.txt %Folder%/freq_count.txt
adb pull /sdcard/log.txt %Folder%/log.txt
adb pull /sdcard/log.csv %Folder%/log.csv

echo ####get splash2 to .\splash2 ...
adb pull   /splash2/ %Folder%/splash2/
echo ####get simcard offline logs to .\SimCardOfflinelogs ...
adb pull   /data/offlinelogs/ %Folder%/SimCardOfflinelogs/
echo ####get huawei zd logs to .\hwzd_logs
adb pull   /data/hwzd_logs/ %Folder%/hwzd_logs/

:: get log server log 
echo ####get logserver log to .\logserver-log1
adb pull   /data/log/ %Folder%/logserver-log1/

:: =========================K3V3 LOG========================================
echo ####get hisi logs to .\hisi_logs
adb shell cat /sys/devices/amba.0/e804e000.hifidsp/dspdumplog
adb pull   /data/hisi_logs/ %Folder%/hisi_logs/

echo ####get hisi dumplog to .\dumplog 
adb pull   /data/dumplog/ %Folder%/dumplog/

::echo ####get secOS log  to .\sec_log
::adb pull   /data/sec_storage/LOG@06060606060606060606060606060606 %Folder%/sec_log/LOG@06060606060606060606060606060606

echo ####get hifi log  to .\hifi
adb pull   /data/hifi/ %Folder%/hifi/

:: =========================AP LOG==========================================
if %ap_opt% EQU 1 (
echo ####get android_logs to .\android_logs ...
adb pull   /data/android_logs/ %Folder%/android_logs/

echo ####get logserver sdcard log to .\logserver-log2
adb pull   /sdcard/log/manual-AP    %Folder%/logserver-log2/manual-AP
adb pull   /sdcard/log/manual-APLocal    %Folder%/logserver-log2/manual-APLocal

echo ####get LogService  .\LogService4.0
adb pull   /sdcard/LogService/    %Folder%/LogService4.0/

echo ####get LogService  .\LogService4.0sdcard
adb pull   /storage/sdcard1/LogService/    %Folder%/LogService4.0sdcard/

echo ####get LogService log  .\LogService4.0sdcard
adb pull   /storage/sdcard1/log/unzip/    %Folder%/LogService4.0sdcard/unzip/
)

:: =========================CP LOG==========================================
if %cp_opt% EQU 1 (
echo ####get modem om log to .\modem_om
mkdir %Folder%\modem_om
adb pull /modem_om/ %Folder%/modem_om/

echo ####get modem log log to .\modem_log
mkdir %Folder%\modem_log
adb pull /modem_log/ %Folder%/modem_log/

adb pull /mnvm2:0  %Folder%/mnvm2_0

echo ####get factory-modemlog  to .\factory-modemlog 
adb pull /data/factory-modemlog/ %Folder%/factory-modemlog/

echo ####get modem log to .\logserver-log2
adb pull   /sdcard/log/modem    %Folder%/logserver-log2/modem
adb pull   /sdcard/log/modem-auto    %Folder%/logserver-log2/modem-auto

echo ####get via modem log to .\viadump
adb pull /data/flashless/ %Folder%/viadump/
)

:: ======================V9R1 LOG===========================================
:: get ap-log in v9r1 
echo ####get /data/ap-log to .\ap-log ...
adb pull  /data/ap-log/  %Folder%/ap-log/

:: get modem log in v9r1 
echo ####get /data/cp-log to .\cp-log ...
adb pull /data/cp-log/ %Folder%/cp-log/

:: get hifi log in v9r1 
echo ####get /data/hifi-log to .\hifi-log ...
adb pull  /data/hifi-log/ %Folder%/hifi-log/

:: get klog in v9r1
echo ####get /data/klog to .\klog
adb pull   /data/klog/      %Folder%/klog/

echo ####get /data/memorydump to .\memorydump
adb pull   /data/memorydump/    %Folder%/memorydump/

echo ####get last kmsg to last_k*** ...
adb pull   /proc/last_kirq             %Folder%\proc\last_kirq
adb pull   /proc/last_kmsg             %Folder%\proc\last_kmsg
adb pull   /proc/last_ktask            %Folder%\proc\last_ktask
echo ####get modemlog to ./mlog_0 ...
adb pull   /data/modemlog/sciRecord1.txt    %Folder%/mlog_0/sciRecord1.txt
adb pull   /data/modemlog/sciRecord0.txt    %Folder%/mlog_0/sciRecord0.txt
adb pull   /data/modemlog/DrvLog/Sim0       %Folder%/mlog_0/Sim0
adb pull   /data/modemlog/DrvLog/Sim1       %Folder%/mlog_0/Sim1
adb pull   /data/modemlog/log               %Folder%/mlog_0/log
adb pull   /mnvm3:0/DrvLog/sciRecord1.txt 	%Folder%/mlog_0/sciRecord1.txt
adb pull   /mnvm3:0/DrvLog/sciRecord0.txt 	%Folder%/mlog_0/sciRecord0.txt
adb pull   /mnvm3:0/DrvLog/Sim0        %Folder%/mlog_0/Sim0
adb pull   /mnvm3:0/DrvLog/Sim1        %Folder%/mlog_0/Sim1
::echo ####get nvme form system ...
::adb pull   /mnvm3:0/NvimDef            %Folder%/mnvm3_0_NvimDef
::adb pull   /mnvm1:0                    %Folder%/mnvm1_0
::adb pull   /mnvm2:0                    %Folder%/mnvm2_0
::adb pull   /3rdmodem/Nvxml             %Folder%/3rdmodem_Nvxml

::=======================common logs ========================================
::
echo ####get RunningTestII log to .\RunningTestII
:: this log in /data/log
:: adb pull    /data/log/RunningTestII                  %Folder%/RunningTestII
adb pull    /data/data/com.huawei.runningtestii/shared_prefs    %Folder%/RunningTestII_shared_prefs

echo ####get adb log to .\adb-log
adb pull  /data/adb/           %Folder%/adb-log/
::adb shell ls /modem_om/balong_om/ | findstr /X log
::if %errorlevel% EQU 0 (
::  echo ####get modem om log to .\modem_om\balong_om
::  mkdir %Folder%\modem_om\balong\log
::  adb pull /modem_om/balong_om/log %Folder%\modem_om\balong_om\log
::)

echo ####get radio logcat to logcat_ril.txt ...
adb shell  logcat -v threadtime -d -t 1000 -b radio > %Folder%\logcat_ril.txt
echo ####get AT logcat to logcat_at.txt ...
adb shell  logcat -v threadtime -d -t 1000 -b radio -s AT > %Folder%\logcat_at.txt
echo ####get bugreport to .\bugreport.txt
adb bugreport > %Folder%\bugreport.txt
echo ####Capture current screen to .\log.png
adb shell /system/bin/screencap -p /sdcard/log.png
adb pull /sdcard/log.png %Folder%/log.png

set del_opt=%3

if "%del_opt:~0,4%"=="/del" (
    set del_log=y
    echo      with [/del] options
) else (
    set /p del_log="Need to del all log(y/n)??(n)"
)
if "%del_log:~0,1%"=="y" (
echo warning delete logs .......
adb shell "rm -rf /data/dontpanic/*"
adb shell "rm -rf /data/system/dropbox/*"
adb shell "rm -rf /data/tombstones/*"
adb shell "rm -rf /data/anr/*"
adb shell "rm -rf /data/hifi/*"
adb shell "rm -rf /data/ap-log/*"
adb shell "rm -rf /data/cp-log/*"
adb shell "rm -rf /data/hifi-log/*"
adb shell "rm /data/klog/*.log"
adb shell "rm -rf /data/memorydump/*"
adb shell "rm -rf /data/adb/*"
adb shell "rm -rf /data/dumplog/*"
adb shell "rm -rf /data/rdr/*"
adb shell "rm -rf /sdcard/log.png"
if %ap_opt% EQU 1 (
adb shell "rm -rf /data/android_logs/*"
adb shell "rm -rf /sdcard/log/manual-AP/*"
adb shell "rm -rf /sdcard/LogService/*"
adb shell "rm -rf /storage/sdcard1/LogService/*"
adb shell "rm -rf /data/hisi_logs/*"
adb shell "rm -rf /data/hwzd_logs/*"
adb shell "rm -rf /data/log/archive/*"
adb shell "rm -rf /data/log/backup/*"
adb shell "rm -rf /sdcard/log/archive/*"
adb shell "rm -rf /sdcard/log/backup/*"
)
if %cp_opt% EQU 1 (
adb shell "rm -rf /sdcard/log/modem/*"
adb shell "rm -rf /data/factory-modemlog/*"
)
)

echo ===============get log end; please check folder=%Folder%=========================
:END
pause
exit
@echo on
