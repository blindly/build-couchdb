cp -rvp /opt/couchdb/* /build${INSTPRE}/

# Init script
cd /build/etc/rc.d/init.d/
sudo ln -s ${INSTPRE}/etc/rc.d/couchdb couchdb
# Sysconfig
cd /build/etc/sysconfig
sudo ln -s ${INSTPRE}/etc/default/couchdb couchdb
cd /build/etc/logrotate.d
sudo ln -s ${INSTPRE}/etc/logrotate.d/couchdb couchdb
# [OPTIONAL] logs and dbs directories in app folder
### NOTE: If not using this, be sure to remove it's creation in before/post-install scripts below.
cd /build${INSTPRE}
sudo rm -rf var/log var/lib/couchdb
sudo ln -s ${INSTPRE}/logs var/log
sudo ln -s ${INSTPRE}/dbs var/lib/couchdb

