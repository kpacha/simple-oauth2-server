#!/bin/sh

# this script is based on https://github.com/purple52/librarian-puppet-vagrant/blob/master/shell/librarian-puppet.sh

PATH=$PATH:/usr/local/bin/

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/etc/puppet/

# Make sure librarian-puppet is installed
$(which librarian-puppet > /dev/null 2>&1)
if [ "$?" -ne '0' ]; then
  apt-get -q -y update

  # Make sure Git is installed
  $(which git > /dev/null 2>&1)
  if [ "$?" -ne '0' ]; then
    echo 'Attempting to install Git.'
    apt-get -q -y install git
    echo 'Git installed.'
  fi

  dpkg -s ruby-json >/dev/null 2>&1
  if [ "$?" -ne '0' -a -n "$(apt-cache search ruby-json)" ]; then
    # Try and install json dependency from package if possible
    apt-get -q -y install ruby-json
  else
    echo 'The ruby_json package was not installed (maybe, it was present). Attempting to install librarian-puppet anyway.'
  fi

  apt-get -q -y install ruby1.9.1-dev

  gem install librarian-puppet
  echo 'Librarian-puppet gem installed.'
fi

if [ ! -d "$PUPPET_DIR" ]; then
  mkdir -p $PUPPET_DIR
fi
cp /vagrant/puppet/Puppetfile $PUPPET_DIR

cd $PUPPET_DIR && librarian-puppet install --verbose --no-use-v1-api

