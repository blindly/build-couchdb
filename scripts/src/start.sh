## SET A PREFIX: This is where the final install will go:
##### I do NOT recommend settings this to '/' - it will give you grief. Only do
##### that if you're absolutely sure; and you know how to amend all of the next steps to suit...!
export INSTPRE=/opt/couchdb
sudo mkdir $INSTPRE
####
sudo rake erl_checkout="OTP_R16B03-1" \
git="https://github.com/apache/couchdb.git 1.6.x" \
install=${INSTPRE}
## This particular install dir is irrelevant as it's just temporary at this point.

sudo mkdir -p /build{${INSTPRE},/etc/rc.d/init.d,/etc/logrotate.d,/etc/sysconfig}

sudo cp -rvp /opt/couchdb/* /build${INSTPRE}/
