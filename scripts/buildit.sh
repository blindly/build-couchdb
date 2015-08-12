#!/bin/bash
rm -rf /opt/couchdb
rm -rf /build

sleep 2

cd ~/build-couchdb

## SET A PREFIX: This is where the final install will go:
##### I do NOT recommend settings this to '/' - it will give you grief. Only do
##### that if you're absolutely sure; and you know how to amend all of the next steps to suit...!
export INSTPRE=/opt/couchdb
sudo mkdir $INSTPRE
mkdir -p $INSTPRE/var/log
# mkdir -p $INSTPRE/var/lib/
####
rake erl_checkout="OTP_R16B03-1" \
git="https://github.com/apache/couchdb.git 1.6.x" \
install=${INSTPRE}
## This particular install dir is irrelevant as it's just temporary at this point.

if [ $? != 0 ] ; then
	echo "Rake failed"
	exit
fi

sleep 2

sudo mkdir -p /build{${INSTPRE},/etc/rc.d/init.d,/etc/logrotate.d,/etc/sysconfig}

sleep 2

sudo cp -rvp /opt/couchdb/* /build${INSTPRE}/
cp -rvp /opt/couchdb/* /build${INSTPRE}/

sleep 2

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

sleep 2

# preinst
cat << EOF > ~/before-install
getent group %{couchdb_group} >/dev/null || groupadd -r %{couchdb_group}
getent passwd %{couchdb_user} >/dev/null || useradd -r -g %{couchdb_group} -d %{couchdb_home} -s /bin/bash -c "Couchdb Database Server" %{couchdb_user}
# If the CouchDB user existed before, make sure it's homedir is correct.
if [ ~%{couchdb_user} != %{couchdb_home} ]; then usermod -d %{couchdb_home} -m %{couchdb_user}; fi
# Cleanup old configs/logs from static instance
OLD_DIRS="/etc/couchdb /var/log/couchdb"
for dir in \$OLD_DIRS; do
    if [ -d \${dir} ]; then
        mv \$dir \$dir.rpmold.\$((RANDOM))
    fi
done
exit 0
EOF
 
# postinst
cat << EOF > ~/after-install
%if 0%{?el5}%{?el6}
/sbin/chkconfig --add %{name}
%else
%systemd_post %{name}.service
%endif
for optional_dir in ${INSTPRE}/{logs,dbs}; do
    if [ ! -d \${optional_dir} ]&&[ ! -L \${optional_dir} ]; then
        mkdir -p \$optional_dir
        chown -R %{couchdb_user}:%{couchdb_group} \${optional_dir} 
    fi
done
# There's definitely a better way of doing this...
chown -R %{couchdb_user}:%{couchdb_group} ${INSTPRE}/var/log
chown -R %{couchdb_user}:%{couchdb_group} ${INSTPRE}/var/run/couchdb
chown -R %{couchdb_user}:%{couchdb_group} ${INSTPRE}/var/lib/couchdb
chown -R %{couchdb_user}:%{couchdb_group} ${INSTPRE}/etc/couchdb
EOF
 
# preun
cat << EOF > ~/before-remove
%if 0%{?el5}%{?el6}
if [ \$1 = 0 ] ; then
/sbin/service %{name} stop >/dev/null 2>&1
/sbin/chkconfig --del %{name}
fi
%else
%systemd_preun %{name}.service
%endif
EOF
 
# postun
cat << EOF > ~/after-remove
%if 0%{?el7}%{?fedora}
%systemd_postun %{name}.service
if [ \$1 -ge 1 ] ; then
# Package upgrade, not uninstall
/usr/bin/systemctl try-restart %{name}.service >/dev/null 2>&1 || :
fi
%endif
 
%if 0%{?fedora} > 16
%triggerun -- %{name} < 1.0.3-5 # Save the current service runlevel info # User must manually run systemd-sysv-convert --apply httpd # to migrate them to systemd targets /usr/bin/systemd-sysv-convert --save %{name} >/dev/null 2>&1 ||:
 
# Run these because the SysV package being removed won't do them
/sbin/chkconfig --del %{name} >/dev/null 2>&1 || :
/bin/systemctl try-restart %{name}.service >/dev/null 2>&1 || :
%endif
EOF
EMAIL=admin@vendor.com
INSTPRE=/opt/couchdb

cd /build

fpm --verbose -s dir -t rpm -n "couchdb" -v "1.6.1_sc" --iteration "1" --epoch "1" \
--rpm-rpmbuild-define 'couchdb_user couchdb' \
--rpm-rpmbuild-define 'couchdb_group couchdb' \
--rpm-rpmbuild-define "couchdb_home ${INSTPRE}/lib/couchdb" \
--rpm-auto-add-directories \
--workdir "/tmp" \
--after-install "~/after-install" \
--before-install "~/before-install" \
--after-remove "~/after-remove" \
--before-remove "~/before-remove" \
--url "http://couchdb.apache.org/" \
--description 'Apache CouchDB is a distributed, fault-tolerant and schema-free
document-oriented database accessible via a RESTful HTTP/JSON API.
Among other features, it provides robust, incremental replication
with bi-directional conflict detection and resolution, and is
queryable and indexable using a table-oriented view engine with
JavaScript acting as the default view definition language.' \
--license "ASL 2.0" \
--category "Applications/Databases" \
--provides "couchdb" \
-m "${EMAIL}" --vendor "${EMAIL}" \
-e opt etc
