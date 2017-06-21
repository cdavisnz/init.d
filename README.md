## SAp Router
Init.d Scripts for SAP Services (SuSE Linux)

The [SAP Router](https://support.sap.com/en/tools/connectivity-tools/saprouter.html) is an SAP program that acts as an intermediate station (proxy) in a network connection between SAP Systems, or between SAP Systems and external networks. SAP Router controls the access to your network (application level gateway), and, as such, is a useful enhancement to an existing firewall system (port filter).

The following provides my recommended installation process for LINUX.

## Installation
###### Set the Install Parameters:
The parameter `$_SAPINST` is a temporary variable for the install identifying the system, it just allows us to multiple saprouters on the one host and make's to look like a standard SAP application instance. For this example i've chosen is 'R' for router followed by the SAP port number '99' i.e. 3299, given me a SAP System ID of 'R99'.
```shell-script
# sudo su - root
# bash
# _SAPINST=R99; export SAPINST
```
###### Create the Users & Group:
Create the <sapsid>adm user account and group that the SAP Router will run under.
```shell-script
# groupadd -g <GID> sapsys
# useradd -u <UID> -g sapsys -c "SAP Router" ${_SAPINST,,}adm -m -s /bin/csh
# passwd ${_SAPINST,,}adm
```
###### SAPCAR:
```shell-script
# cp SAPCAR_<VERSION>.SAR /usr/sbin/SAPCAR
# chown root:sapsys /usr/sbin/SAPCAR
# chmod 755 /usr/sbin/SAPCAR
```
###### Create the direcorty structure:
```shell-script
# mkdir -p /usr/sap/${_SAPINST}/saprouter/exe
# mkdir /usr/sap/${_SAPINST}/saprouter/tmp
# mkdir /usr/sap/${_SAPINST}/saprouter/sec
# mkdir -p /usr/sap/${_SAPINST}/saprouter/log
```
###### Create a sample 'saprouttab':
The following just creates a sample saprouttab with all connections denied as SAP Router needs this file to start. Please amended as per own requirements.
```shell-script
# echo "D * * *" > /usr/sap/${_SAPINST}/saprouter/saprouttab
# chmod 644 /usr/sap/${_SAPINST}/saprouter/saprouttab
```
###### Extract the Software:
```shell-script
# SAPCAR saprouter_<VERSION>.SAR -xvf /usr/sap/${_SAPINST}/saprouter/exe/
# SAPCAR SAPCRYPTOLIBP_<VERSION>.SAR -xvf /usr/sap/${_SAPINST}/saprouter/exe/
# chown -R ${_SAPINST,,}adm:sapsys /usr/sap/${_SAPINST}/
# chmod -r 755 /usr/sap/${_SAPINST}/
```

###### Install the init.d script:
```shell-script
#
```
###### Super user do:
```shell-script
#
```
###### Define the user environment:
```shell-script
#
```
###### Create the Certificate (Optional):
The common name is your own, if it is a SNC connection to SAP then it is the SAP issued value.
```shell-script
# sudo su - ${_SAPINST,,}adm
# cd /usr/sap/${_SAPINST}/saprouter/sec
# setenv SECUDIR=/usr/sap/${_SAPINST}/saprouter/sec
# sapgenpse get_pse -v -a sha256WithRsaEncryption -s 2048 -r certreq -p ${_SAPINST}SSLS.pse "CN=<Name>, OU=<Customer Number>, OU=SAProuter, O=SAP, C=DE"
# sapgenpse seclogin -p ${_SAPINST}SSLS.pse -O r90adm
```
```shell-script
# sapgenpse import_own_cert -c reponse.crt -p ${_SAPINST}SSLS.pse
```
###### Start SAProuter
```shell-script
#
```
