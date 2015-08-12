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
