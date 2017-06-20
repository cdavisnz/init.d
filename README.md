## SAPROUTER
Init.d Scripts for SAP Services (SuSE Linux)

The SAP Router is an SAP program that acts as an intermediate station (proxy) in a network connection between SAP Systems, or between SAP Systems and external networks. SAP Router controls the access to your network (application level gateway), and, as such, is a useful enhancement to an existing firewall system (port filter).

The following provides a recommend installation process for LINUX.

###### Set the install parameters
```Shell
# sudo su - root
# bash
# _SAPINST=R99; export SAPINST
```
###### Defined users & groups
```Shell
# groupadd -g <GID>
# useradd -u <UID> -g sapsys -c "SAP Router" ${_SAPINST,,}adm -m -s /bin/csh
# passwd ${_SAPINST,,}adm
```
###### SAPCAR
```Shell
#
```
###### Create the direcorty structure 
```Shell
# mkdir -p /usr/sap/${_SAPINST}/saprouter/exe
# mkdir /usr/sap/${_SAPINST}/saprouter/tmp
# mkdir -p /usr/sap/${_SAPINST}/log
```
###### Create a sample 'saprouttab'
```Shell
# echo "D * * *" > /usr/sap/${_SAPINST}/saprouter/saprouttab
# chmod 644 /usr/sap/${_SAPINST}/saprouter/saprouttab
```
###### Extract the Software
```Shell
# SAPCAR saprouter_.SAR -xvf /usr/sap/${_SAPINST}/saprouter/exe/
# SAPCAR SAPCRYPTOLIBP_.SAR -xvf /usr/sap/${_SAPINST}/saprouter/exe/
# chown -R ${_SAPINST,,}adm:sapsys /usr/sap/${_SAPINST}/
# chmod -r 755 /usr/sap/${_SAPINST}/
```
###### Create the Certificate
```Shell
#
```
###### Install the init.d script
```Shell
#
```
###### Super user do
```Shell
#
```
###### Define the user environment 
```Shell
#
```
