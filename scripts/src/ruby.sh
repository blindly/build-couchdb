if [ -z $(ruby -v|awk '{print $2}') ] ; then
	\curl -L https://get.rvm.io | bash -s stable
	source /etc/profile.d/rvm.sh
	rvm install 1.9.3 --with-openssl-dir=/usr  ## This may fail at first, run it again if it does.
	rvm use 1.9.3 --default
	ruby -v    ## Should show 1.9.3
	gem install fpm    ## This sits for a while before printing
fi
