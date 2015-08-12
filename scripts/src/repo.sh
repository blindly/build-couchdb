
if [ -e ~/build-couchdb ] ; then
	rm -rf ~/build-couchdb
fi

cd ~
git clone https://github.com/blindly/build-couchdb
cd build-couchdb
git submodule init 
git submodule update
git submodule update
git submodule update
