#!/bin/bash
################################################################################
# Author: Abdelmajid Elhamdaoui. Refrence: Yenthe Van Ginneken
################################################################################

# OCA Modules
REP_OCA_WEB="https://github.com/OCA/web.git"
REP_OCA_SERVER_TOOLS="https://github.com/OCA/server-tools.git"
REP_OCA_SERVER_UX="https://github.com/OCA/server-ux.git"
REP_OCA_REPORT_ENGINE="https://github.com/OCA/reporting-engine.git"
REP_OCA_ACC_FIN_TOOLS="https://github.com/OCA/account-financial-tools.git"
REP_QUEUE="https://github.com/OCA/queue.git"
REP_CUSTOM_1="False"
REP_CUSTOM_1_NAME=""
REP_CUSTOM_1_BRANCH=$OE_VERSION

OE_USER="odoo12"		
OE_HOME="/opt/$OE_USER"		
OE_HOME_EXT="/opt/$OE_USER/odoo-server"		
#The default port where this Odoo instance will run under (provided you use the command -c in the terminal)		
#Set to true if you want to install it, false if you don't need it or have it already installed.		
INSTALL_WKHTMLTOPDF="True"		
#Set to true if you want to install it, false if you don't need it or have it already installed.		
INSTALL_POSTGRESQL="False"		
CREATE_USER_POSTGRESQL="True"		
#Set the default Odoo port (you still have to use -c /etc/odoo-server.conf for example to use this.)		
OE_PORT="8069"		
#Choose the Odoo version which you want to install. For example: 10.0, 9.0, 8.0, 7.0 or saas-6. When using 'trunk' the master version will be installed.		
#IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 10.0		
OE_VERSION="12.0"		
# Set this to True if you want to install Odoo 10 Enterprise!		
#Default = False		
IS_ENTERPRISE="False"		
#set the superadmin password		
#Generic Password odooxxx		
OE_SUPERADMIN="odooxxx"		
OE_CONFIG="${OE_USER}-server"    

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Create server config file"
sudo su root -c "echo '[options]' > /etc/${OE_CONFIG}.conf"
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Change server config file"

#sudo su root -c "echo ' ' >> /etc/${OE_CONFIG}.conf"


#logfile
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "echo 'logrotate = True' >> /etc/${OE_CONFIG}.conf"

echo -e "* Change default xmlrpc port"
sudo su root -c "echo 'xmlrpc_port = $OE_PORT' >> /etc/${OE_CONFIG}.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' > $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/odoo-bin --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

echo -e "* Create init file"
cat <<EOF > ~/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Enterprise Business Applications
# Description: ODOO Business Applications
### END INIT INFO
PATH=/bin:/sbin:/usr/bin
DAEMON=$OE_HOME_EXT/odoo-bin
NAME=$OE_CONFIG
DESC=$OE_CONFIG

# Specify the user name (Default: odoo).
USER=$OE_USER

# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="/etc/${OE_CONFIG}.conf"

# pidfile
PIDFILE=/var/run/\${NAME}.pid

# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"
[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0
checkpid() {
[ -f \$PIDFILE ] || return 1
pid=\`cat \$PIDFILE\`
[ -d /proc/\$pid ] && return 0
return 1
}

case "\${1}" in
start)
echo -n "Starting \${DESC}: "
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
stop)
echo -n "Stopping \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
echo "\${NAME}."
;;

restart|force-reload)
echo -n "Restarting \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
sleep 1
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
*)
N=/etc/init.d/\$NAME
echo "Usage: \$NAME {start|stop|restart|force-reload}" >&2
exit 1
;;

esac
exit 0
EOF

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG



echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults

echo -e "* Starting Odoo Service"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Addons folder: $OE_USER/$OE_CONFIG/addons/"
echo "Start Odoo service: sudo service $OE_CONFIG start"
echo "Stop Odoo service: sudo service $OE_CONFIG stop"
echo "Restart Odoo service: sudo service $OE_CONFIG restart"
