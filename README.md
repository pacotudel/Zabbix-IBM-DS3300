# IBM ds3300 SAN Zabbix 2.4 Template

I have to get status of some ds3300 SAN Storage and here is the template and script used for this work.


##Scripts

### [ds3300_status.sh](https://github.com/pacotudel/Zabbix-IBM-DS3300/blob/master/ds3300_status.sh)
	Script to get data of the SAN.

### [Template_IBM_Cabina_DS3300.xml](https://github.com/pacotudel/Zabbix-IBM-DS3300/blob/master/Template_IBM_Cabina_DS3300.xml)
	Template for Zabbix 2.4
	It's make for work on a zabbix proxy that is in the same subnet as the ds3300 IBM San configuration port.
	It's need to have installed the tool /opt/IBM_DS/client/SMcli on the zabbix proxy