#!/bin/sh
# Updated: 04/11/2016 Craig.Davis
#          20/06/2017 Craig.Davis: Allows for SNC
#
# /etc/init.d/z_sapr99
#
# chkconfig: 345 90 10
# description: Start SAP Router R99

### BEGIN INIT INFO
# Provides: z_sapr99
# Required-Start: $network $syslog $remote_fs $time
# X-UnitedLinux-Should-Start:
# Required-Stop:
# Default-Start: 3 5
# Default-Stop: 0 1 2 6
# Short-Description: Start the SAProuter
# Description: Start the SAProuter
### END INIT INFO

RETVAL=0

# Source function library.
. /etc/rc.status
rc_reset

SAPSYSTEMNAME=R99
SAPUSER=r99adm
SAPBASE=/usr/sap/${SAPSYSTEMNAME}/saprouter
SAPEXEC=${SAPBASE}/exe/saprouter
SAPHOST=`hostname --ip-address`
SAPPORT=3299

SECUDIR=${SAPBASE}/sec; export SECUDIR
SNC_LIB=${SAPBASE}/exe/libsapcrypto.so; export SNC_LIB
SAPSNCP="offCN=R90AWS, OU=0000333798, OU=SAProuter, O=SAP, C=DE"

LOCKFILE=${SAPBASE}/tmp/z_sap${SAPUSER}.tmp
LOGFILE=${SAPBASE}/tmp/saprouter-`whoami`.log
PATH=${PATH}:$SAPBASE/exe; export PATH

stop()
{
    echo -n $"Shutdown SAPRouter ${SAPSYSTEMNAME}: "

    if [ -d ${SAPBASE}/exe ]; then
        ${SAPEXEC} -s -H ${SAPHOST} -S ${SAPPORT} > ${LOGFILE} 2>&1
        RETVAL=$?
    else
        RETVAL=1
    fi

    if [ ${RETVAL} -eq 0 ]; then
        rm -f ${LOCKFILE}
        rc_status -v
    else
        rc_status -v
    fi
    return ${RETVAL}
}

start()
{
    echo -n $"Startup SAPRouter ${SAPSYSTEMNAME}: "

    if [ -d ${SAPBASE}/exe ]; then

        case "$SAPSNCP" in
            CN=*)
            /sbin/startproc -u `id -u ${SAPUSER}` ${SAPEXEC} -r -H ${SAPHOST} -I ${SAPHOST} -S ${SAPPORT} -Z -D -E -J 1048576 -W 60000 -K p:\"$SAPSNCP\" -R ${SAPBASE}/saprouttab -G ${SAPBASE}/log/dev_saprouter -T ${SAPBASE}/log/dev_rout
> ${LOGFILE} 2>&1 &;;
            *)
            /sbin/startproc -u `id -u ${SAPUSER}` ${SAPEXEC} -r -H ${SAPHOST} -I ${SAPHOST} -S ${SAPPORT} -Z -D -E -J 1048576 -W 60000 -R ${SAPBASE}/saprouttab -G ${SAPBASE}/log/dev_saprouter -T ${SAPBASE}/log/dev_rout > ${LOGFILE} 2>&1
&;;
        esac

        /sbin/startproc -u `id -u ${SAPUSER}` ${SAPEXEC} -l -H ${SAPHOST} -S ${SAPPORT} > ${LOGFILE} 2>&1
        RETVAL=$?
    else
        RETVAL=1
    fi

    if [ ${RETVAL} -eq 0 ]; then
        touch ${LOCKFILE}
        rc_status -v
    else
        rc_status -v
    fi
    return ${RETVAL}
}

reload()
{
    echo -n $"Reload SAPRouter ${SAPSYSTEMNAME}: "

    if [ -d ${SAPBASE}/exe ]; then
        /sbin/startproc -u `id -u ${SAPUSER}` ${SAPEXEC} -n -H ${SAPHOST} -S ${SAPPORT} -R ${SAPBASE}/saprouttab > ${LOGFILE} 2>&1
        RETVAL=$?
    else
        RETVAL=1
    fi

    if [ ${RETVAL} -eq 0 ]; then
        touch ${LOCKFILE}
        rc_status -v
    else
        rc_status -v
    fi
    return ${RETVAL}
}
status()
{
    echo -n $"Status SAPRouter ${SAPSYSTEMNAME}: "

    if [ -d ${SAPBASE}/exe ]; then

        /sbin/startproc -u `id -u ${SAPUSER}` ${SAPEXEC} -l -H ${SAPHOST} -S ${SAPPORT} > ${LOGFILE} 2>&1
        RETVAL=$?
    else
        RETVAL=1
    fi

    if [ ${RETVAL} -eq 0 ]; then
        touch ${LOCKFILE}
        rc_status -v
    else
        rc_status -v
    fi
    return ${RETVAL}
}

upgrade()
{
    if [ -d $SAPBASE/exe ]; then
        if [ -x "/usr/bin/aws" ]; then
            touch $SAPBASE/exe/.upgrading
            find $SAPBASE/exe/* -user $SAPUSER ! -name sapcontrol -exec rm -f {} \;
            aws s3 sync s3://software-sap/SAPROUTER_LINUX/exe $SAPBASE/exe --quiet
            chmod -f 755 $SAPBASE/exe/_sap.sh
            $SAPBASE/exe/_sap.sh $SAPBASE/exe $SAPBASE $SAPUSER
            rm -f $SAPBASE/exe/.upgrading
       fi
    fi
}

case $1 in
  stop)
    stop
  ;;
  start)
    upgrade
    start
  ;;
  restart)
    stop
    upgrade
    start
  ;;
  reload)
    reload
  ;;
  status)
    status
  ;;
  *)
    echo "Usage $0 (start|stop|restart|reload|status)"
    exit 1;
    ;;
esac
exit ${RETVAL}