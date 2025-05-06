#Skrypt Mikrotik v3.2

/system scheduler
add interval=1w name=aktualizacje-scheduler on-event=aktualizacje policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-05-05 start-time=00:00:00
    /system scheduler
add interval=4w2d name=kopie-scheduler on-event=kopia_zapasowa+mail policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-05-05 start-time=00:00:00
add interval=6h name=monitorowanie_log on-event=monitorowanie_logowania \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-05-06 start-time=00:00:00
/system script
add dont-require-permissions=no name=aktualizacje owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \_Initialize variables\r\
    \n:local actualChannel \"\"\r\
    \n:local actualCurrentVersion \"\"\r\
    \n:local actualLatestVersion \"\"\r\
    \n:local deviceSerial \"\"\r\
    \n:local deviceModel \"\"\r\
    \n:local deviceArchitecture \"\"\r\
    \n:local routerName [/system identity get name]\r\
    \n# Get device information\r\
    \n:local deviceSerial [/system routerboard get serial-number]\r\
    \n:local deviceModel [/system routerboard get model]\r\
    \n:local deviceArchitecture [/system resource get architecture-name]\r\
    \n\r\
    \n# Check for software updates\r\
    \n/system package update check-for-updates do={\r\
    \n    :set actualChannel \$\"channel\"\r\
    \n    :set actualCurrentVersion [/system package get [find name=\"routeros\
    \"] version]\r\
    \n    :set actualLatestVersion \$\"latest-version\"\r\
    \n}\r\
    \n\r\
    \n# Define filename for storing last known version\r\
    \n:local dataFile \"SoftChecker.txt\"\r\
    \n\r\
    \n# Check if the file exists, if not, create it and initialize contents\r\
    \n:if ([:len [/file find name=\$dataFile]] = 0) do={\r\
    \n    /file add name=\$dataFile contents=\"\"\r\
    \n}\r\
    \n\r\
    \n# Read old software version from the file\r\
    \n:local oldSoftwareVersion [/file get [/file find name=\$dataFile] conten\
    ts]\r\
    \n\r\
    \n# Compare versions and send appropriate email\r\
    \n:if (\$actualLatestVersion != \$oldSoftwareVersion) do={\r\
    \n\r\
    \n    # Update the file with the new version\r\
    \n    /file set [/file find name=\$dataFile] contents=\$actualLatestVersio\
    n\r\
    \n\r\
    \n    # Send notification about new version\r\
    \n    /tool e-mail send to=\"mail@mail.pl\" subject=(\"MTK Aktualizacj\
    e -> Dost\EApna jest nowa wersja RouterOS - \$routerName \" . \$actualLate\
    stVersion . \" dla urz\B9dzenia \" . [/system identity get name]) body=(\"\
    Channel: \" . \$actualChannel . \"\\r\\nActual version: \" . \$actualCurre\
    ntVersion . \"\\r\\nNew version: \" . \$actualLatestVersion . \"\\r\\nSeri\
    al Number: \" . \$deviceSerial . \"\\r\\nModel: \" . \$deviceModel . \"\\r\
    \\nArchitecture: \" . \$deviceArchitecture . \"\\r\\nDate: \" . [/system c\
    lock get date] . \" \" . [/system clock get time])\r\
    \n\r\
    \n} else={\r\
    \n\r\
    \n    # Send notification that system is up-to-date\r\
    \n    /tool e-mail send to=\"mail@mail.pl\" subject=\"MTK Aktualizacje\
    \_-> Wersja RouterOS jest aktualna - \$routerName \" body=(\"Wersja Router\
    OS jest aktualna\\r\\nChannel: \" . \$actualChannel . \"\\r\\nActual versi\
    on: \" . \$actualCurrentVersion . \"\\r\\nNew version: \" . \$actualLatest\
    Version . \"\\r\\nSerial Number: \" . \$deviceSerial . \"\\r\\nModel: \" .\
    \_\$deviceModel . \"\\r\\nArchitecture: \" . \$deviceArchitecture . \"\\r\
    \\nDate: \" . [/system clock get date] . \" \" . [/system clock get time])\
    \r\
    \n}\r\
    \n"
add dont-require-permissions=no name=kopia_zapasowa+mail owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    log info \"Rozpoczynam tworzenie kopii zapasowej\"\r\
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
    \n:local emailBody \"Kopia zapasowa dla urz\B9dzenia: \$routerName\\r\\nSe\
    rial Number: \$deviceSerial\\r\\nModel: \$deviceModel\\r\\nArchitecture: \
    \$deviceArchitecture\\r\\nData: \$currentDate\"\r\
    \n/tool e-mail send to=\"mail@mail.pl\" subject=\$emailSubject body=\$\
    emailBody file=\$backupName\r\
    \n:delay 10s\r\
    \n/file remove [/file find name=\$backupName]\r\
    \n:log info \"Usuni\EAto kopi\EA \$backupName\""
add dont-require-permissions=yes name=monitorowanie_logowania owner=admin \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source="# Inicjalizacja zmiennych\r\
    \n:local currentDate [/system clock get date]\r\
    \n:local currentTime [/system clock get time]\r\
    \n:local hostname [/system identity get name]\r\
    \n:local successfulLogins \"\"\r\
    \n:local failedLogins \"\"\r\
    \n:local successCount 0\r\
    \n:local failedCount 0\r\
    \n\r\
    \n# Pobieranie log\F3w z ostatnich 24 godzin\r\
    \n:foreach logEntry in=[/log find where topics~\"system;info\" or topics~\
    \"system;error\" time>([/system clock get time]-6h)] do={\r\
    \n    :local logMessage [/log get \$logEntry message]\r\
    \n    \r\
    \n    # Sprawdzanie czy to log logowania\r\
    \n    :if (\$logMessage~\"logged in\") do={\r\
    \n        :set successfulLogins (\$successfulLogins . \"\\n\" . [/log get \
    \$logEntry time] . \" - \" . \$logMessage)\r\
    \n        :set successCount (\$successCount + 1)\r\
    \n    }\r\
    \n    \r\
    \n    # Sprawdzanie czy to log nieudanego logowania\r\
    \n    :if (\$logMessage~\"login failure\") do={\r\
    \n        :set failedLogins (\$failedLogins . \"\\n\" . [/log get \$logEnt\
    ry time] . \" - \" . \$logMessage)\r\
    \n        :set failedCount (\$failedCount + 1)\r\
    \n    }\r\
    \n}\r\
    \n\r\
    \n:local emailSubjectSuccess (\"MTK Raport UDANYCH logowa\F1 - \" . \$host\
    name . \" - \" . \$currentDate)\r\
    \n:local emailBodySuccess \"=== RAPORT UDANYCH LOGOWA\D1 DO MIKROTIK ===\\\
    n\"\r\
    \n:set emailBodySuccess (\$emailBodySuccess . \"Router: \" . \$hostname . \
    \"\\n\")\r\
    \n:set emailBodySuccess (\$emailBodySuccess . \"Data: \" . \$currentDate .\
    \_\"\\n\")\r\
    \n:set emailBodySuccess (\$emailBodySuccess . \"Czas: \" . \$currentTime .\
    \_\"\\n\\n\")\r\
    \n\r\
    \n:set emailBodySuccess (\$emailBodySuccess . \"=== UDANE LOGOWANIA (\" . \
    \$successCount . \") ===\\n\")\r\
    \n:if (\$successCount > 0) do={\r\
    \n    :set emailBodySuccess (\$emailBodySuccess . \$successfulLogins . \"\
    \\n\\n\")\r\
    \n\t/tool e-mail send to=\"mail@mail.pl\" subject=\$emailSubjectSucces\
    s body=\$emailBodySuccess\r\
    \n}\r\
    \n\r\
    \n# Tworzenie tre\9Cci emaila dla nieudanych logowa\F1\r\
    \n:local emailSubjectFailed (\"MTK Raport NIEUDANYCH logowa\F1 - \" . \$ho\
    stname . \" - \" . \$currentDate)\r\
    \n:local emailBodyFailed \"=== RAPORT NIEUDANYCH LOGOWA\D1 DO MIKROTIK ===\
    \\n\"\r\
    \n:set emailBodyFailed (\$emailBodyFailed . \"Router: \" . \$hostname . \"\
    \\n\")\r\
    \n:set emailBodyFailed (\$emailBodyFailed . \"Data: \" . \$currentDate . \
    \"\\n\")\r\
    \n:set emailBodyFailed (\$emailBodyFailed . \"Czas: \" . \$currentTime . \
    \"\\n\\n\")\r\
    \n\r\
    \n:set emailBodyFailed (\$emailBodyFailed . \"=== NIEUDANE LOGOWANIA (\" .\
    \_\$failedCount . \") ===\\n\")\r\
    \n:if (\$failedCount > 0) do={\r\
    \n    :set emailBodyFailed (\$emailBodyFailed . \$failedLogins . \"\\n\\n\
    \")\r\
    \n\t/tool e-mail send to=\"mail@mail.pl\" subject=\$emailSubjectFailed\
    \_body=\$emailBodyFailed\r\
    \n} \r\
    \n"
/tool e-mail
set from=mail@mail.pl port=465 server=mail.pl tls=yes user=\
    mail@mail.pl
