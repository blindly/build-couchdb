EMAIL=support@EMC.com
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
