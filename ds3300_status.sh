#!/bin/bash
#########################################################
#
# IBM DSxx health monitoring
# 
# Usage:  ds3300_status.sh <DS_controller> OPTIONS
# Params:
#         $1 V3700 ip
#         $2 user
#         $3 password
#         $4 parameter to measure (lsarray, lsdrive)
#              IF $4=lsarray $5 is number of drive
#              IF $4=lsdrive $5 is number of drive
#
# Output: 
#         
#
# Francisco Tudel 2015
#
# 
#
#########################################################


####################################################
# Function Declaration

###########################################################
# Get data from DS3300
###########################################################
function getdatafromds3300(){
	if [[ "$DEBUG" == "1" ]] ; then echo "getdatafromds3300:" $1 $2 $3; fi
	if [[ "$1" == "lsdrive" ]] ; then
		/opt/IBM_DS/client/SMcli $3 -c "show alldrives;" -quick | grep "GB" > $2
		if [[ "$DEBUG" == "1" ]] ; then echo "getdatafromds3300: -"$1"-"; fi
		#RESULT=$(cat "$FILE")
	fi
	if [ "$1" == "lscontrollers" ] ; then
		/opt/IBM_DS/client/SMcli $3 -c "show allcontrollers;" -quick > $2
		#RESULT=$(cat "$FILE")
	fi
	if [ "$1" == "lsethernet" ] ; then
		/opt/IBM_DS/client/SMcli $3 -c "show allcontrollers;" -quick > $2
		#| grep -E 'Link.*status.*Up | Link.*status.*Down' | grep -v 'priority' | awk '{print $3}' | sed sed ':a;N;$!ba;s/\n/ /g' > $2
		#RESULT=$(cat "$FILE")
	fi
	if [ "$1" == "lsstoragesubsystemprofile" ] ; then
		/opt/IBM_DS/client/SMcli $3 -c "show storagesubsystem profile;" -quick > $2
		#RESULT=$(cat "$FILE")
	fi
	if [ "$1" == "lsallhostports" ] ; then
		/opt/IBM_DS/client/SMcli $3 -c "show allhostports;" -quick > $2
		#RESULT=$(cat "$FILE")
	fi
	if [ "$1" == "lsalldrivechannels" ] ; then
		/opt/IBM_DS/client/SMcli $3 -c "show alldrivechannels stats;" -quick > $2
		#RESULT=$(cat "$FILE")
	fi
	if [ "$1" == "lsalllogicaldrives" ] ; then
		/opt/IBM_DS/client/SMcli $3 -c "show alllogicaldrives summary;" -quick > $2
		#RESULT=$(cat "$FILE")
	fi

	if [[ "$DEBUG" == "1" ]] ; then echo "getdatafromds3300: - fin -"; fi
	if [[ "$DEBUG" == "1" ]] ; then cat "$2" ; fi
}

if [ $# -lt 2 ]
 then
    	echo "SCRIPT_ERROR: Not enough parameters"
    	echo " Usage: v3700_status.sh <SVC_IP> <SVC_USER> <SVC_PWD> <Parameter to list> <Data for the parameter>"
    	# echo " Parameters: lsdrive,lsarray,lsvdisk,lsenclosure,lsenclosurebattery,lsenclosurecanister,lsenclosurepsu,lsenclosureslot,logstatus,logerror"
	echo " Parameters: lsdrive,lscontrollers,lsethernet,lsstoragesubsystemprofile"
  exit 2
fi

# Chequeo de parametros
CHKPARAM=1
if [[ "$2" == "lsdrive" ]] ; then CHKPARAM=0 ; fi
if [[ "$2" == "lscontrollers" ]] ; then CHKPARAM=0 ; fi
if [[ "$2" == "lsethernet" ]] ; then CHKPARAM=0 ; fi
if [[ "$2" == "lsstoragesubsystemprofile" ]] ; then CHKPARAM=0 ; fi
if [[ "$CHKPARAM" == "1" ]] ; then exit ; fi


PATH_CACHE=/var/tmp
#PATH_CACHE=/home/administrador/ds3300/log
SEGUNDOS_CADUCIDAD=60
RESULT=''
FILE="$PATH_CACHE"/"$2"_"$1"
#COMMAND="/opt/IBM_DS/client/SMcli" $1 -c " show alldrives;" -quick |' grep  "GB" 
#COMMAND="/opt/IBM_DS/client/SMcli" 


DEBUG="0"

#Escribir si debug
if [[ "$DEBUG" == "1" ]] ; then clear; fi
if [[ "$DEBUG" == "1" ]] ; then echo "Debug ON"; fi
if [[ "$DEBUG" == "1" ]] ; then echo "Segundos de caducidad: " $SEGUNDOS_CADUCIDAD ; fi 
if [[ "$DEBUG" == "1" ]] ; then echo "Fichero cache: " $FILE ; fi
#if [[ "$DEBUG" == "1" ]] ; then echo "Comando: " $COMMAND ; fi

if [ -f "$FILE" ] ;
then
    if [[ "$DEBUG" == "1" ]] ; then echo "Fichero existe           : " $FILE ; fi
    # Fichero existe, ver si esta caducado
    AHORA=$(date +%s)
    if [[ "$DEBUG" == "1" ]] ; then echo "Timestamp ahora          : " $AHORA ; fi
    FICHERO=$(stat -c %Y "$PATH_CACHE/$2_$1")
    if [[ "$DEBUG" == "1" ]] ; then echo "Timestamp fichero        : " $FICHERO ; fi
    FICHERO=`expr $FICHERO + $SEGUNDOS_CADUCIDAD`
    if [[ "$DEBUG" == "1" ]] ; then echo "Timestamp fichero y caduc: " $FICHERO ; fi
    
    if [ $AHORA -gt $FICHERO ] ;
    then
	#Fichero caducado
        #echo Fichero caducado
	if [[ "$DEBUG" == "1" ]] ; then echo "Fichero caducado Ejecutar... " ; fi
	getdatafromds3300 $2 $FILE $1
	RESULT=$(cat "$FILE")
	if [[ "$DEBUG" == "1" ]] ; then echo "Ejecutado... " ; fi
	#if [[ "$DEBUG" == "1" ]] ; then echo "Fichero leido... " $RESULT ; fi
    else
	#echo Fichero NO caducado
	if [[ "$DEBUG" == "1" ]] ; then echo "Fichero no caducado leyendo... " ; fi
	RESULT=$(cat "$FILE")
	# if [[ "$DEBUG" == "1" ]] ; then echo "Fichero no caducado leido... " $RESULT ; fi
    fi
else
	# echo Fichero NO encontrado
	if [[ "$DEBUG" == "1" ]] ; then echo "Fichero NO encontrado. " $FILE ; fi
	if [[ "$DEBUG" == "1" ]] ; then echo "Creando. "  ; fi
	getdatafromds3300 $2 $FILE $1
	RESULT=$(cat "$FILE")
	if [[ "$DEBUG" == "1" ]] ; then echo "Creado. "  ; fi
fi


#
# Check the health status via cli
#


#lsdrive -> state of drives
if [ $2 == 'lsdrive' ]; then
    BUSCA=$3
    if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido: "  ; fi
	if [[ "$DEBUG" == "1" ]] ; then echo "RESULT: " $RESULT ; fi
    echo "$RESULT" | awk '$2=='"$BUSCA"' {print $3}'
fi

#lscontrollers -> state of controllers
if [ $2 == 'lscontrollers' ]; then
    	BUSCA=$3
    	if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido: "  ; fi
    	RESULT2=`echo "$RESULT" | grep -E 'Controller.*Enclosure|Status' | grep -v 'Up' | grep -v 'Optimal'  | sed ':a;N;$!ba;s/\n/ /g'`
	if [[ "$BUSCA" == "1" ]] ; then 
		echo "$RESULT2" | awk '{print $8}';
	fi
	if [[ "$BUSCA" == "2" ]] ; then 
		echo "$RESULT2" | awk '{print $16}';
	fi
fi

#lsethernet -> state of ethernet
if [ $2 == 'lsethernet' ]; then
	BUSCA=$3
	if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido: "  ; fi
	RESULT2=`echo "$RESULT" | grep -E 'Link.*status.*Up | Link.*status.*Down'  | sed ':a;N;$!ba;s/\n/ /g'`
	if [[ "$BUSCA" == "1" ]] ; then 
		echo "$RESULT2" | awk '{print $3}';
	fi
	if [[ "$BUSCA" == "2" ]] ; then 
		echo "$RESULT2" | awk '{print $6}';
	fi

fi

#lsstoragesubsystemprofile-> state of different parts of storage susbystem
if [ $2 == 'lsstoragesubsystemprofile' ]; then
	if [ $3 == 'psu' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (PSU):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'Power.*supply' | sed ':a;N;$!ba;s/\n/ /g'`
		if [[ "$BUSCA" == "1" ]] ; then 
			echo "$RESULT2" | awk '{print $4}';
		fi
		if [[ "$BUSCA" == "2" ]] ; then 
			echo "$RESULT2" | awk '{print $13}';
		fi
	fi
	if [ $3 == 'bat' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (BAT):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'Battery.*status' | sed ':a;N;$!ba;s/\n/ /g'`
		if [[ "$BUSCA" == "1" ]] ; then
			echo "$RESULT2" | awk '{print $3}';
		fi
		if [[ "$BUSCA" == "2" ]] ; then 
			echo "$RESULT2" | awk '{print $6}';
		fi
	fi
	if [ $3 == 'psufan' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (PSU FAN):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'Power-fan' | sed ':a;N;$!ba;s/\n/ /g'`
		if [[ "$BUSCA" == "1" ]] ; then
			echo "$RESULT2" | awk '{print $5}';
		fi
		if [[ "$BUSCA" == "2" ]] ; then 
			echo "$RESULT2" | awk '{print $10}';
		fi
	fi
	if [ $3 == 'fan' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (FAN):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'Fan.*Status' | sed ':a;N;$!ba;s/\n/ /g'`
		if [[ "$BUSCA" == "1" ]] ; then
			echo "$RESULT2" | awk '{print $3}';
		fi
		if [[ "$BUSCA" == "2" ]] ; then 
			echo "$RESULT2" | awk '{print $6}';
		fi
	fi
	if [ $3 == 'temp' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (TEMP):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'Temperature.*sensor.*status' | sed ':a;N;$!ba;s/\n/ /g'`
		if [[ "$BUSCA" == "1" ]] ; then
			echo "$RESULT2" | awk '{print $4}';
		fi
		if [[ "$BUSCA" == "2" ]] ; then 
			echo "$RESULT2" | awk '{print $8}';
		fi
		if [[ "$BUSCA" == "3" ]] ; then 
			echo "$RESULT2" | awk '{print $12}';
		fi
		if [[ "$BUSCA" == "4" ]] ; then 
			echo "$RESULT2" | awk '{print $16}';
		fi

	fi
	if [ $3 == 'logdrv' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (RAID):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'SAS|SATA' | grep -v 'Standby' | grep -v 'Current' | grep -v 'Gbps' | grep -v 'Drive' | head -n -1 | sed ':a;N;$!ba;s/\n/ /g'`
		if [[ "$BUSCA" == "1" ]] ; then
			echo "$RESULT2" | awk '{print $2}';
		fi
		if [[ "$BUSCA" == "2" ]] ; then 
			echo "$RESULT2" | awk '{print $9}';
		fi
		if [[ "$BUSCA" == "3" ]] ; then 
			echo "$RESULT2" | awk '{print $16}';
		fi
		if [[ "$BUSCA" == "4" ]] ; then 
			echo "$RESULT2" | awk '{print $23}';
		fi

	fi
	if [ $3 == 'logdrvname' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (RAID name):"  ; fi

		RESULT2=`echo "$RESULT" | grep -E 'SAS|SATA' | grep -v 'Standby' | grep -v 'Current' | grep -v 'Gbps' | grep -v 'Drive' | head -n -1 | sed ':a;N;$!ba;s/\n/ /g'`
		if [[ "$DEBUG" == "1" ]] ; then echo "$RESULT2" ; fi
		if [[ "$BUSCA" == "1" ]] ; then
			echo "$RESULT2" | awk '{print $1}';
		fi
		if [[ "$BUSCA" == "2" ]] ; then 
			echo "$RESULT2" | awk '{print $8}';
		fi
		if [[ "$BUSCA" == "3" ]] ; then 
			echo "$RESULT2" | awk '{print $15}';
		fi
		if [[ "$BUSCA" == "4" ]] ; then 
			echo "$RESULT2" | awk '{print $22}';
		fi

	fi

	if [ $3 == 'firm' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (FIRM):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'Firmware' | head -n1 | awk '{print $3; exit}';`
		echo "$RESULT2" ;
	fi
	if [ $3 == 'hotsparestandby' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (HOT SPARE STANDBY):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'Standby' | head -n1 | awk '{print $2; exit}';`
		echo "$RESULT2" ;
	fi
	if [ $3 == 'hotspareinuse' ]; then
		BUSCA=$4
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (HOT SPARE INUSE):"  ; fi
		RESULT2=`echo "$RESULT" | grep -E 'In.*use' | head -n1 | awk '{print $3; exit}';`
		echo "$RESULT2" ;
	fi
	if [ $3 == 'test' ]; then
		if [[ "$DEBUG" == "1" ]] ; then echo "Valor Leido (TEST):"  ; fi
		RESULT2=""
		echo "$RESULT2" ;
	fi


fi