#/bin/sh

#Check if hana db server
#Détedrmination de la DB

function hanadb() {
DBIN="/usr/sap/codilog/hana/bin/backup/"
    DLOG="/usr/sap/codilog/hana/log/"
    DCONF="/usr/sap/codilog/hana/conf/"
    USERNAME=$(cat $DCONF/CONF | awk -F ':' '{print $1}')
    PASSWORD=$(cat $DCONF/CONF | awk -F ':' '{print $2}')
    SID=$(pgrep -a "sapstartsrv" | grep HDB | awk -F '/' '{print $4}')
    SN=$(pgrep -a "sapstartsrv" | grep HDB | awk -F '/' '{print $5}' | awk -F 'HDB' '{print $2}')
    DEXE="/usr/sap/$SID/HDB$SN/exe/"
    $DBIN/hdbsql -u $USERNAME -p $PASSWORD -n localhost -d $SID -i $SN -I $DBIN/check_backup.sql -o $DLOG/check_backup.log > /dev/null
    _CR=$?
    if [[ $_CR -eq 0 ]];then
        state=$(cat /usr/sap/codilog/hana/log/check_backup.log| grep "successful\|failed\|running\|canceled") > /dev/null
        if [[ $state == '"failed"' ]];then 
            echo "Backup $SID en erreur"
            exit 2
        elif [[ $state == '"successful"' ]];then
            echo "Backup $SID successful"
            exit 0
        elif [[ $state == '"running"' ]];then
            echo "Backup $SID successful"
            exit 0
        elif [[ $state == '"canceled"' ]];then
            echo "Backup $SID canceled"
            exit 2
        fi
    else
        echo "CR = $_CR - Requête en erreur"
        exit 3
    fi
}

if pgrep -x "hdbindexserver" > /dev/null
then
    hanadb
elif pgrep -x "vserver" > /dev/null 
then
    maxdb
else
    echo "Pas de server de DB détecté"
    exit 2
fi