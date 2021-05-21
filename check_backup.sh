#/bin/sh

#Check if hana db server
if pgrep -x "hdbindexserver" > /dev/null
then
        DEXE="/usr/sap/DDB/HDB02/exe/"
    DBIN="/usr/sap/codilog/hana/bin/backup/"
    DLOG="/usr/sap/codilog/hana/log/"
    DCONF="/usr/sap/codilog/hana/conf/"
    USERNAME=$(cat $DCONF/CONF | awk -F ':' '{print $1}')
    PASSWORD=$(cat $DCONF/CONF | awk -F ':' '{print $2}')
    $DBIN/hdbsql -u $USERNAME -p $PASSWORD -n localhost -d DDB -i 02 -I $DBIN/check_backup.sql -o $DLOG/check_backup.log > /dev/null
    _CR=$?
    if [[ $_CR -eq 0 ]];then
        state=$(cat /usr/sap/codilog/hana/log/check_backup.log| grep "successful\|failed") > /dev/null
        if [[ $state == '"failed"' ]];then 
            echo "Backup DDB en erreur"
            exit 2
        elif [[ $state == '"successful"' ]];then
            echo "Backup DDB successful"
            exit 0
        fi
    else
        echo "CR = $_CR - Requête en erreur"
        exit 3
    fi
else
    echo "Pas de server hana détecté"
    exit 2
fi