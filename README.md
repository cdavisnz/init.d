# SAP Router

> Status: 

The [SAP Router](https://support.sap.com/en/tools/connectivity-tools/saprouter.html) is an SAP program that acts as an intermediate station (proxy) in a network connection between SAP Systems, or between SAP Systems and external networks. SAP Router controls the access to your network (application level gateway), and, as such, is a useful enhancement to an existing firewall system (port filter).

The following provides my recommended installation process for LINUX and includes an /etc/init.d script.
 
## Installation
###### PARAMETERS:
The parameter `$_SAPINST` is a temporary variable for the install identifying the system, it just allows us to install multiple saprouters on the one host and gives the apperance that the instal looks like a standard SAP application layout. For this example i've chosen is 'R' for router followed by the SAP port number '99' i.e. 3299, given me a SAP System ID of 'R99'.
```shell
# sudo su - root
# bash
# _SAPINST=R99; export SAPINST
```
###### ACCOUNTS:
Create the \<sapsid\>adm user account and group that the SAP router process will run under, provide the groupid \<GID\> and userid \<UID\> as required.
```shell-script
# groupadd -g <GID> sapsys
# useradd -u <UID> -g sapsys -c "SAP Router" ${_SAPINST,,}adm -m -s /bin/csh
# passwd ${_SAPINST,,}adm
```
###### SOFTWARE:
Ensure the SAPCAR executable is downloaded and available for use.
```shell-script
# cp SAPCAR_<VERSION>.SAR /usr/sbin/SAPCAR
# chown root:sapsys /usr/sbin/SAPCAR
# chmod 755 /usr/sbin/SAPCAR
```
###### DIRECTORY:
Create the following direcorty structure for the SAP router installation.
```shell-script
# mkdir -p /usr/sap/${_SAPINST}/saprouter/exe
# mkdir /usr/sap/${_SAPINST}/saprouter/tmp
# mkdir /usr/sap/${_SAPINST}/saprouter/sec
# mkdir -p /usr/sap/${_SAPINST}/saprouter/log
```
###### PERMISSION TABLE:
The following just creates a sample 'saprouttab' file with all connections denied. The SAP router needs this file to start, please amended as per your own requirements. sap.help.com [Route Permission Table](https://uacp2.hana.ondemand.com/viewer/e245703406684d8a81812f4c6334eb2f/7.51.0/en-US/486c7a3fc1504e6ce10000000a421937.html)
```shell-script
# echo "D * * *" > /usr/sap/${_SAPINST}/saprouter/saprouttab
# chmod 644 /usr/sap/${_SAPINST}/saprouter/saprouttab
```
###### SOFTWARE:
Extract the SAP software for the SAP router and SAP crypto library to the executable direcory.
```shell-script
# SAPCAR -xvf saprouter_<VERSION>.SAR -R /usr/sap/${_SAPINST}/saprouter/exe/
# SAPCAR -xvf SAPCRYPTOLIBP_<VERSION>.SAR -R /usr/sap/${_SAPINST}/saprouter/exe/
# chown -R ${_SAPINST,,}adm:sapsys /usr/sap/${_SAPINST}/
# chmod -r 755 /usr/sap/${_SAPINST}/
```
###### INIT.D:
Download the init.d script `z_sapr99.sh` from this repository.
```shell-script
# cd /etc/init.d
# wget ...
# chown root:sapsys z_sapr99
# chmod 750 z_sapr99
```
Adjust the values for `$SAPSYSTEMNAME`, `$SAPUSER`, and `$SAPPORT` as required. If your SAP router is to be SNC enabled, please provide the Common Name within the parameter `SAPSNCP` i.e. SAPSNCP="CN=\<Name\>, OU=\<Customer Number\>, OU=SAProuter, O=SAP, C=DE". To disable, leave the parameter as is. If the SAP router is to be placed on another SAP System ID, rename the script to reflect. 
```shell-script
..
SAPSYSTEMNAME=R99
SAPUSER=r99adm
SAPBASE=/usr/sap/${SAPSYSTEMNAME}/saprouter
SAPEXEC=${SAPBASE}/exe/saprouter
SAPHOST=`hostname --ip-address`
SAPPORT=3299

SECUDIR=${SAPBASE}/sec; export SECUDIR
SNC_LIB=${SAPBASE}/exe/libsapcrypto.so; export SNC_LIB
SAPSNCP=""
..
```
###### SUDO:
Via sudo allow the \<sapsid\>adm rights to access the init.d script, edit the sudoers.d file as required.
```shell-script
# visudo
```
```
...
# SAP Router Commands
r99adm ALL = (root) NOPASSWD: /bin/systemctl start z_sapr99
r99adm ALL = (root) NOPASSWD: /bin/systemctl stop z_sapr99
r99adm ALL = (root) NOPASSWD: /bin/systemctl status z_sapr99
r99adm ALL = (root) NOPASSWD: /bin/systemctl reload z_sapr99
```
###### ENVIRONMENT:
Create the follow user environment for the SAP router \<sapsid\>adm account.
```shell-script
# vi /home/${_SAPINST,,}adm/.cshrc
```
Copy in the following content and save the file.
```shell-script
# @(#) $Id: //bas/721_REL/src/krn/tpls/ind/SAPSRC.CSH#1 $ SAP
# systename
setenv SAPSYSTEMNAME R99
set prompt="`hostname`:$LOGNAME \!> "
# no autologout
set autologout = 0
# number of commands saved in history list
set history = 50
# path
setenv PATH ${PATH}:/usr/bin/nohup:/usr/sap/${SAPSYSTEMNAME}/saprouter/exe
# sapgenpse
setenv SECUDIR /usr/sap/${SAPSYSTEMNAME}/saprouter/sec
setenv SNC_LIB /usr/sap/${SAPSYSTEMNAME}/saprouter/exe/libsapcrypto.so
# define some nice aliases
alias dir 'ls -l'
alias l 'ls -abxCF'
alias h 'history'
alias cdexe 'cd /usr/sap/$SAPSYSTEMNAME/saprouter/exe'
alias cdsec 'cd /usr/sap/$SAPSYSTEMNAME/saprouter/sec'
alias cdD 'cd /usr/sap/$SAPSYSTEMNAME/saprouter'
alias cdR 'cd /usr/sap/$SAPSYSTEMNAME/saprouter'
alias saprouttab 'vi /usr/sap/$SAPSYSTEMNAME/saprouter/saprouttab'
alias startsap 'sudo /bin/systemctl start z_sapr99'
alias stopsap 'sudo /bin/systemctl stop z_sapr99'
alias statussap 'sudo /bin/systemctl status z_sapr99'
alias reloadsap 'sudo /bin/systemctl reload z_sapr99'
```
```shell-script
# chown ${_SAPINST,,}adm:sapsys /home/${_SAPINST,,}adm/.cshrc
# chmod 640 /home/${_SAPINST,,}adm/.cshrc
```
###### CERTIFICATE (Optional):
If Secure Network Communications (SNC) is required, generate the required certififate. The common name is your own, if it is a SNC connection to SAP then it is the value issued by SAP. For more inforamtion of this visit the SAP support link below for Connectivity Tools SAP Router.
```shell-script
# sudo su - ${_SAPINST,,}adm
# setenv _SAPINST=R99
# cd /usr/sap/${_SAPINST}/saprouter/sec
# setenv SECUDIR=/usr/sap/${_SAPINST}/saprouter/sec
# sapgenpse get_pse -v -a sha256WithRsaEncryption -s 2048 -r certreq -p ${_SAPINST}SSLS.pse "CN=<Name>, ..."
# sapgenpse seclogin -p ${_SAPINST}SSLS.pse -O ${_SAPINST,,}ad
# chmod 600 /usr/sap/${_SAPINST}/saprouter/sec/${_SAPINST}SSLS.pse /usr/sap/${_SAPINST}/saprouter/sec/cred_v2
```
The following command imports the 'reponse.crt' file from a Certifiate Authority, in this case SAP SE.
```shell-script
# sapgenpse import_own_cert -c reponse.crt -p ${_SAPINST}SSLS.pse
# sapgenpse get_my_name -p ${_SAPINST}SSLS.pse
```
###### COMMANDS:
As root
```shell-script
# sudo su - 
# cd /etc/init.d
# ./z_sapr99 start
redirecting to systemctl start .service
Startup SAPRouter R99:                                                done
sapds4e1:/etc/init.d # ./z_sapr99 stop
redirecting to systemctl stop .service
Shutdown SAPRouter R99:                                               done
```
As \<sapsid\>adm, stop and start the SAP router via the predefined alias's. i.e. stopsap
```
# sudo su - r99adm
# stopsap
# startsap
# statussap
z_sapr99.service - LSB: Start the SAProuter
   Loaded: loaded (/etc/init.d/z_sapr99)
   Active: active (running) since Thu 2017-06-22 15:00:35 NZST; 2s ago
  Process: 78976 ExecStart=/etc/init.d/z_sapr99 start (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/z_sapr99.service
           └─79024 /usr/sap/R99/saprouter/exe/saprouter -r -H <HOST> -I <HOST> .... 
#
```
## Recommendations
Ensure that SAP router and SAP crypto library executable's are patched regularly, this addresses any know security or software issues.

## Reference & Support Documentation
support.sap.com : Connectivity Tools SAP Router
- https://support.sap.com/en/tools/connectivity-tools/saprouter.html

sap.help.com : SAP Router
- https://uacp2.hana.ondemand.com/viewer/e245703406684d8a81812f4c6334eb2f/7.51.0/en-US/487612ed5ca5055ee10000000a42189b.html

suse.com : SAProuter Integration
SUSE Linux Enterprise Server for SAP Applications 12 SP2
- https://www.suse.com/documentation/sles-for-sap-12/singlehtml/book_s4s/book_s4s.html#sec.s4s.configure.saprouter

Enjoy!
