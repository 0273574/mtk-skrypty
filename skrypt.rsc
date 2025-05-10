#Skrypt Mikrotik v0.4
    /system scheduler
    add interval=1w name=skrypty-scheduler on-event=skrypty_update policy=\
        ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
        start-date=2025-05-05 start-time=00:00:00
    add interval=1w name=soft_update-scheduler on-event=soft_update policy=\
        ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
        start-date=2025-05-05 start-time=00:10:00
    add interval=4w2d name=backup-scheduler on-event=backup policy=\
        ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
        start-date=2025-05-05 start-time=00:30:00
    add interval=6h name=login on-event=login policy=\
        ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
        start-date=2025-05-06 start-time=00:20:00
    /system script
    add dont-require-permissions=no name=soft_update owner=admin policy=\
        ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
        local mail \"mail@mail.pl\"\
        \n:local actualChannel \"\"\
        \n:local actualCurrentVersion \"\"\
        \n:local actualLatestVersion \"\"\
        \n:local deviceSerial \"\"\
        \n:local deviceModel \"\"\
        \n:local deviceArchitecture \"\"\
        \n\
        \n:local routerName [/system identity get name]\
        \n:local deviceSerial [/system routerboard get serial-number]\
        \n:local deviceModel [/system routerboard get model]\
        \n:local deviceArchitecture [/system resource get architecture-name]\
        \n\
        \n/system package update check-for-updates do={\
        \n    :set actualChannel \$\"channel\"\
        \n    :set actualCurrentVersion [/system package get [find name=\"routeros\
        \"] version]\
        \n    :set actualLatestVersion \$\"latest-version\"\
        \n}\
        \n\
        \n:if (\$actualLatestVersion != \$actualCurrentVersion) do={\
        \n    :log info \"MTK -> Nowa wersja oprogramowania jest dostepna, zostani\
        e wykonana aktualizacja\"\
        \n    /tool e-mail send to=\$mail subject=(\"MTK Aktualizacje -> Dostepna \
        jest nowa wersja RouterOS - \$routerName \" . \$actualLatestVersion . \" d\
        la urzadzenia \" . [/system identity get name]) body=(\"Channel: \" . \$ac\
        tualChannel . \"\\r\\nActual version: \" . \$actualCurrentVersion . \"\\r\
        \\nNew version: \" . \$actualLatestVersion . \"\\r\\nSerial Number: \" . \
        \$deviceSerial . \"\\r\\nModel: \" . \$deviceModel . \"\\r\\nArchitecture:\
        \_\" . \$deviceArchitecture . \"\\r\\nDate: \" . [/system clock get date] \
        . \" \" . [/system clock get time])\
        \n    /system package update download\
        \n    :delay 10s\
        \n} else={\
        \n    :log info \"MTK -> Wersja RouterOS jest aktualna, nie zostana podjet\
        e zadne dzialania\"\
        \n    /tool e-mail send to=\$mail subject=\"MTK Aktualizacje -> Wersja Rou\
        terOS jest aktualna - \$routerName \" body=(\"Wersja RouterOS jest aktualn\
        a\\r\\nChannel: \" . \$actualChannel . \"\\r\\nActual version: \" . \$actu\
        alCurrentVersion . \"\\r\\nNew version: \" . \$actualLatestVersion . \"\\r\
        \\nSerial Number: \" . \$deviceSerial . \"\\r\\nModel: \" . \$deviceModel \
        . \"\\r\\nArchitecture: \" . \$deviceArchitecture . \"\\r\\nDate: \" . [/s\
        ystem clock get date] . \" \" . [/system clock get time])\
        \n}"
    add dont-require-permissions=no name=backup owner=admin policy=\
        ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":lo\
        cal mail \"mail@mail.pl\"\r\
        \n:log info \"Rozpoczynam tworzenie kopii zapasowej\"\r\
        \n:local currentDate [/system clock get date]\r\
        \n:local backupName (\"backup_\" . \$currentDate . \".backup\")\r\
        \n/system backup save name=\$backupName\r\
        \n:delay 10s\r\
        \n:log info \"Rozpoczynam wysy\B3anie kopii zapasowej na e-mail\"\r\
        \n:local routerName [/system identity get name]\r\
        \n:local deviceSerial [/system routerboard get serial-number]\r\
        \n:local deviceModel [/system routerboard get model]\r\
        \n:local deviceArchitecture [/system resource get architecture-name]\r\
        \n:local emailSubject (\"MTK Backup -> \" . \$routerName)\r\
        \n:local emailBody \"Kopia zapasowa dla urzadzenia: \$routerName\\r\\nSeri\
        al Number: \$deviceSerial\\r\\nModel: \$deviceModel\\r\\nArchitecture: \$dev\
        iceArchitecture\\r\\nData: \$currentDate\"\r\
        \n\r\
        \n/tool e-mail send to=\$mail subject=\$emailSubject body=\$emailBody file=\
        \$backupName\r\
        \n:delay 10s\r\
        \n/file remove [/file find name=\$backupName]\r\
        \n:log info \"Usuni\EAto kopi\EA \$backupName\""
    add dont-require-permissions=yes name=login owner=praktykant policy=\
        ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":lo\
        cal mail \"mail@mail.pl\"\
        \n:local currentDate [/system clock get date]\
        \n:local currentTime [/system clock get time]\
        \n:local hostname [/system identity get name]\
        \n:local successfulLogins \"\"\
        \n:local failedLogins \"\"\
        \n:local successCount 0\
        \n:local failedCount 0\
        \n\
        \n:foreach logEntry in=[/log find where topics~\"system;info\" or topics~\"s\
        ystem;error\" time>([/system clock get time]-6h)] do={\
        \n    :local logMessage [/log get \$logEntry message]\
        \n    \
        \n    :if (\$logMessage~\"logged in\") do={\
        \n        :set successfulLogins (\$successfulLogins . \"\\n\" . [/log get \$\
        logEntry time] . \" - \" . \$logMessage)\
        \n        :set successCount (\$successCount + 1)\
        \n    }\
        \n    \
        \n    :if (\$logMessage~\"login failure\") do={\
        \n        :set failedLogins (\$failedLogins . \"\\n\" . [/log get \$logEntry\
        \_time] . \" - \" . \$logMessage)\
        \n        :set failedCount (\$failedCount + 1)\
        \n    }\
        \n}\
        \n\
        \n:local emailSubjectSuccess (\"MTK Raport UDANYCH logowan - \" . \$hostname\
        \_. \" - \" . \$currentDate)\
        \n:local emailBodySuccess \"=== RAPORT UDANYCH LOGOWAN DO MIKROTIK ===\\n\"\
        \n:set emailBodySuccess (\$emailBodySuccess . \"Router: \" . \$hostname . \"\
        \\n\")\
        \n:set emailBodySuccess (\$emailBodySuccess . \"Data: \" . \$currentDate . \
        \"\\n\")\
        \n:set emailBodySuccess (\$emailBodySuccess . \"Czas: \" . \$currentTime . \
        \"\\n\\n\")\
        \n\
        \n:set emailBodySuccess (\$emailBodySuccess . \"=== UDANE LOGOWANIA (\" . \$\
        successCount . \") ===\\n\")\
        \n:if (\$successCount > 0) do={\
        \n    :set emailBodySuccess (\$emailBodySuccess . \$successfulLogins . \"\\n\
        \\n\")\
        \n\t/tool e-mail send to=\$mail subject=\$emailSubjectSuccess body=\$emailBo\
        dySuccess\
        \n}\
        \n:log info \"MTK -> logi zostaly wyslane do serwera\"\
        \n:local emailSubjectFailed (\"MTK Raport NIEUDANYCH logowan - \" . \$hostna\
        me . \" - \" . \$currentDate)\
        \n:local emailBodyFailed \"=== RAPORT NIEUDANYCH LOGOWAN DO MIKROTIK ===\\n\
        \"\
        \n:set emailBodyFailed (\$emailBodyFailed . \"Router: \" . \$hostname . \"\\\
        n\")\
        \n:set emailBodyFailed (\$emailBodyFailed . \"Data: \" . \$currentDate . \"\
        \\n\")\
        \n:set emailBodyFailed (\$emailBodyFailed . \"Czas: \" . \$currentTime . \"\
        \\n\\n\")\
        \n\
        \n:set emailBodyFailed (\$emailBodyFailed . \"=== NIEUDANE LOGOWANIA (\" . \
        \$failedCount . \") ===\\n\")\
        \n:if (\$failedCount > 0) do={\
        \n    :set emailBodyFailed (\$emailBodyFailed . \$failedLogins . \"\\n\\n\")\
        \n\t/tool e-mail send to=\$mail subject=\$emailSubjectFailed body=\$emailBod\
        yFailed\
        \n} \
        \n"
