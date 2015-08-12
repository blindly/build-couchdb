curl -o /build${INSTPRE}/etc/couchdb/local.ini http://dgunix.com/wp-content/uploads/2013/11/local.ini_.txt
 
## Set username and password correctly for authentication:
CDBUSER=admin
CDBPASS=correcthorsebatterystaple
 
## Replace these in the downloaded config
sudo sed -i "s/^userhere =/$CDBUSER =/" /build${INSTPRE}/etc/couchdb/local.ini
sudo sed -i "s/ = passwordhere$/ = $CDBPASS/" /build${INSTPRE}/etc/couchdb/local.ini
