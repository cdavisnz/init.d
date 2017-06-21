# SAP Router

The [SAP Router](https://support.sap.com/en/tools/connectivity-tools/saprouter.html) is an SAP program that acts as an intermediate station (proxy) in a network connection between SAP Systems, or between SAP Systems and external networks. SAP Router controls the access to your network (application level gateway), and, as such, is a useful enhancement to an existing firewall system (port filter).

The following provides my recommended installation process for LINUX.
 
## Installation
###### PARAMETERS:
The parameter `$_SAPINST` is a temporary variable for the install identifying the system, it just allows us to multiple saprouters on the one host and make's to look like a standard SAP application instance. For this example i've chosen is 'R' for router followed by the SAP port number '99' i.e. 3299, given me a SAP System ID of 'R99'.
```shell
# sudo su - root
# bash
# _SAPINST=R99; export SAPINST
```
###### ACCOUNTS:
Create the <sapsid>adm user account and group that the SAP Router will run under.
```shell-script
# groupadd -g <GID> sapsys
# useradd -u <UID> -g sapsys -c "SAP Router" ${_SAPINST,,}adm -m -s /bin/csh
# passwd ${_SAPINST,,}adm
```
###### SOFTWARE:
Ensure the SAPCAR executable is downloaded and available.
```shell-script
# cp SAPCAR_<VERSION>.SAR /usr/sbin/SAPCAR
# chown root:sapsys /usr/sbin/SAPCAR
# chmod 755 /usr/sbin/SAPCAR
```
###### DIRECTORY:
Create the following direcorty structure for the SAP Router.
```shell-script
# mkdir -p /usr/sap/${_SAPINST}/saprouter/exe
# mkdir /usr/sap/${_SAPINST}/saprouter/tmp
# mkdir /usr/sap/${_SAPINST}/saprouter/sec
# mkdir -p /usr/sap/${_SAPINST}/saprouter/log
```
###### PERMISSION TABLE:
The following just creates a sample 'saprouttab' file with all connections denied. The SAP Router needs this file to start, please amended as per your own requirements.
```shell-script
# echo "D * * *" > /usr/sap/${_SAPINST}/saprouter/saprouttab
# chmod 644 /usr/sap/${_SAPINST}/saprouter/saprouttab
```
###### SOFTWARE:
Extract the SAP Software for the SAP Router and SAP Crypto Library.
```shell-script
# SAPCAR -xvf saprouter_<VERSION>.SAR -R /usr/sap/${_SAPINST}/saprouter/exe/
# SAPCAR -xvf SAPCRYPTOLIBP_<VERSION>.SAR -R /usr/sap/${_SAPINST}/saprouter/exe/
# chown -R ${_SAPINST,,}adm:sapsys /usr/sap/${_SAPINST}/
# chmod -r 755 /usr/sap/${_SAPINST}/
```
###### INIT.D:
```shell-script
#
```
###### SUOD:
```shell-script
#
```
###### ENVIRONMENT:
```shell-script
#
```
###### CERTIFICATE (Optional):
If Secure Network Communications (SNC) is required, generate the required certififate. The common name is your own, if it is a SNC connection to SAP then it is the value issued by SAP.
```shell-script
# sudo su - ${_SAPINST,,}adm
# setenv _SAPINST=R99
# cd /usr/sap/${_SAPINST}/saprouter/sec
# setenv SECUDIR=/usr/sap/${_SAPINST}/saprouter/sec
# sapgenpse get_pse -v -a sha256WithRsaEncryption -s 2048 -r certreq -p ${_SAPINST}SSLS.pse "CN=<Name>, OU=<Customer Number>, OU=SAProuter, O=SAP, C=DE"
# sapgenpse seclogin -p ${_SAPINST}SSLS.pse -O ${_SAPINST,,}ad
# chmod 600 /usr/sap/${_SAPINST}/saprouter/sec/${_SAPINST}SSLS.pse /usr/sap/${_SAPINST}/saprouter/sec/cred_v2
```
The following command imports the reponse.crt file from a Certifiate Authority, in this case SAP SE.
```shell-script
# sapgenpse import_own_cert -c reponse.crt -p ${_SAPINST}SSLS.pse
# sapgenpse get_my_name -p ${_SAPINST}SSLS.pse
```
###### COMMANDS:
```shell-script
#
```

## Reference
support.sap.com : Connectivity Tools SAP Router
https://support.sap.com/en/tools/connectivity-tools/saprouter.html

sap.help.com : SAP Router
https://uacp2.hana.ondemand.com/viewer/e245703406684d8a81812f4c6334eb2f/7.51.0/en-US/487612ed5ca5055ee10000000a42189b.html

suse.com : SAProuter Integration
SUSE Linux Enterprise Server for SAP Applications 12 SP2
https://www.suse.com/documentation/sles-for-sap-12/singlehtml/book_s4s/book_s4s.html#sec.s4s.configure.saprouter
https://www.suse.com/documentation/sles-for-sap-12/singlehtml/book_s4s/book_s4s.html#sec.s4s.configure.saprouter

